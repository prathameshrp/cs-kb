require 'find'
require 'yaml'
require 'fileutils'
require 'shellwords'
require 'date'

module Jekyll
  class ObsidianPage < Page
    def initialize(site, base, dir, name, note_path, relative_dir, permalink)
      @site = site
      @base = base
      @dir = dir
      @name = name

      self.process(name)
      self.read_yaml(File.dirname(note_path), File.basename(note_path))

      # Use 'post' layout by default
      self.data['layout'] ||= 'post'
      self.data['permalink'] = permalink
      
      if self.data['tags'].is_a?(String)
        self.data['tags'] = self.data['tags'].split(',').map(&:strip)
      elsif self.data['tags'].nil?
        self.data['tags'] = []
      end
      self.data['tags'].map!(&:strip)

      self.data['relative_path'] = note_path
      self.data['relative_dir'] = relative_dir
    end
  end

  class ObsidianConverterGenerator < Generator
    safe true
    priority :high

    def self.slugify(str)
      # Slugify preserving the path and folder names exactly (lowercase, space/slash to hyphen)
      str.downcase.strip.gsub(/[^a-z0-9]+/, '-')
    end

    def self.make_permalink(rel_path)
      parts = rel_path.split('/')
      # Slugify each individual segment of the path
      slugified_parts = parts.map { |seg| slugify(File.basename(seg, ".md")) }.reject(&:empty?)
      "/#{slugified_parts.join('/')}/"
    end

    def self.insert_into_tree(tree_node, segments, note_title, note_url)
      if segments.size == 1
        # It's the note file itself
        tree_node['files'] << {
          'title' => note_title,
          'url' => note_url
        }
      else
        # It's a directory
        dir_name = segments[0]
        tree_node['dirs'][dir_name] ||= {
          'name' => dir_name,
          'dirs' => {},
          'files' => []
        }
        insert_into_tree(tree_node['dirs'][dir_name], segments[1..-1], note_title, note_url)
      end
    end

    def self.flatten_tree(node, level, accum)
      # Sort directories and files alphabetically to maintain clean index order
      sorted_dirs = node['dirs'].keys.sort
      sorted_files = node['files'].sort_by { |f| f['title'] }
      
      sorted_dirs.each do |dir_name|
        child_node = node['dirs'][dir_name]
        accum << {
          'type' => 'dir',
          'name' => dir_name,
          'level' => level,
          'id' => slugify(dir_name)
        }
        flatten_tree(child_node, level + 1, accum)
      end
      
      sorted_files.each do |file|
        accum << {
          'type' => 'file',
          'title' => file['title'],
          'url' => file['url'],
          'level' => level
        }
      end
    end

    def generate(site)
      notes_dir = File.join(site.source, '_notes')
      unless Dir.exist?(notes_dir)
        Jekyll.logger.warn "ObsidianConverter:", "_notes directory does not exist at #{notes_dir}!"
        return
      end

      whitelist_prefixes = site.config['published_folders'] || []
      note_title_to_url = {}
      note_title_to_title = {}
      notes_metadata = []

      # Pass 1: Scan and identify all whitelisted notes (ONLY if published: true)
      Dir.glob(File.join(notes_dir, "**/*.md")).each do |note_path|
        rel_path = note_path.sub("#{notes_dir}/", "")
        is_whitelisted = whitelist_prefixes.any? { |prefix| rel_path.start_with?(prefix) }
        next unless is_whitelisted
        
        # Skip templates, daily notes, and attachments globally
        next if rel_path.downcase.include?("template") || rel_path.downcase.include?("daily") || rel_path.downcase.include?("attachment")

        # Read frontmatter and only load if published: true
        begin
          content_str = File.read(note_path)
          if content_str =~ /\A(---\s*\n[\s\S]*?\n---\s*\n)/
            frontmatter = YAML.safe_load($1, permitted_classes: [Date, Time])
            next unless frontmatter && (frontmatter['published'] == true || frontmatter['published'] == "true")
          else
            next
          end
        rescue => e
          Jekyll.logger.error "ObsidianConverter:", "Error reading frontmatter for #{note_path}: #{e.message}"
          next
        end

        parts = rel_path.split('/')
        subject_slug = self.class.slugify(parts[0])
        subject_title = parts[0].gsub('-', ' ')
        
        permalink = self.class.make_permalink(rel_path)
        clean_name = File.basename(rel_path, ".md")
        
        note_title_to_url[clean_name] = permalink
        note_title_to_url[clean_name.downcase] = permalink
        note_title_to_title[clean_name.downcase] = clean_name
        
        # Get last git commit date for this specific file
        git_date = nil
        begin
          git_date_raw = `git -C #{notes_dir.shellescape} log --format="%ai" -1 -- #{note_path.shellescape} 2>/dev/null`.strip
          git_date = DateTime.parse(git_date_raw) unless git_date_raw.empty?
        rescue
          # Fallback: file mtime
          git_date = File.mtime(note_path)
        end

        notes_metadata << {
          path: note_path,
          dir: File.dirname(permalink),
          name: "#{clean_name}.md",
          relative_dir: File.dirname(rel_path),
          title: clean_name,
          permalink: permalink,
          subject_slug: subject_slug,
          subject_title: subject_title,
          subject_folder: parts[0],
          segments: parts[1..-1], # Middle folders + filename
          last_modified: git_date
        }
      end

      # Sort notes by file path (sequential progress)
      notes_metadata.sort_by! { |n| n[:path] }
      
      Jekyll.logger.info "ObsidianConverter:", "Found #{notes_metadata.size} published notes."

      # Initialize backlinks map
      backlinks_map = Hash.new { |h, k| h[k] = [] }
      pages_list = []

      # Create Page objects
      notes_metadata.each do |note|
        page = ObsidianPage.new(
          site, 
          site.source, 
          note[:dir], 
          note[:name], 
          note[:path], 
          note[:relative_dir], 
          note[:permalink]
        )
        
        page.data['title'] ||= note[:title]
        title_key = page.data['title'].downcase

        # Inject last modified date into page data
        if note[:last_modified]
          page.data['last_modified_at'] = note[:last_modified].strftime('%B %-d, %Y')
          page.data['last_modified_iso'] = note[:last_modified].strftime('%Y-%m-%d')
        end
        
        pages_list << { 
          page: page, 
          title: page.data['title'], 
          path: note[:path],
          subject_slug: note[:subject_slug],
          subject_title: note[:subject_title],
          subject_folder: note[:subject_folder],
          segments: note[:segments],
          last_modified: note[:last_modified]
        }
      end

      # Group lessons by subject to compute sequential next/prev progressions
      notes_by_subject = {}
      pages_list.each do |item|
        notes_by_subject[item[:subject_slug]] ||= []
        notes_by_subject[item[:subject_slug]] << item
      end

      notes_by_subject.each do |subject_slug, list|
        list.each_with_index do |item, idx|
          page = item[:page]
          
          # Previous progression button
          if idx > 0
            prev_item = list[idx - 1]
            page.data['previous_lesson'] = {
              'title' => prev_item[:title],
              'url' => prev_item[:page].url
            }
          end
          
          # Next progression button
          if idx < list.size - 1
            next_item = list[idx + 1]
            page.data['next_lesson'] = {
              'title' => next_item[:title],
              'url' => next_item[:page].url
            }
          end
        end
      end

      # Build tree navigation structure
      subjects_trees = {}
      pages_list.each do |item|
        subject_slug = item[:subject_slug]
        subjects_trees[subject_slug] ||= {
          'title' => item[:subject_title],
          'folder' => item[:subject_folder],
          'dirs' => {},
          'files' => []
        }
        
        self.class.insert_into_tree(
          subjects_trees[subject_slug], 
          item[:segments], 
          item[:title], 
          item[:page].url
        )
      end

      # Flatten tree navigation for easy sidebar loops in Liquid
      site.config['curriculum'] = {}
      subjects_trees.each do |subject_slug, tree|
        flat_items = []
        self.class.flatten_tree(tree, 0, flat_items)
        
        # Pull description dynamically from README.md inside the subject folder
        description = ""
        subject_folder = tree['folder']
        readme_path = File.join(notes_dir, subject_folder, "README.md")
        if File.exist?(readme_path)
          begin
            readme_content = File.read(readme_path)
            # Scan for blockquotes (lines starting with >)
            quotes = readme_content.scan(/^\s*>\s*(.*)$/).map { |m| m[0].strip }
            description = quotes.join(" ") unless quotes.empty?
          rescue => e
            Jekyll.logger.error "ObsidianConverter:", "Error reading README for #{subject_folder}: #{e.message}"
          end
        end

        # Default fallback description if none is found
        if description.empty?
          description = "A reference guide for #{tree['title']}. Prepend lines with '>' in your #{subject_folder}/README.md to display a description card here."
        end

        # Find the published modules/subfolders
        subject_prefixes = whitelist_prefixes.select { |pref| pref.start_with?(subject_folder + "/") }
        modules_list = subject_prefixes.map do |pref|
          pref.sub(subject_folder + "/", "").chomp("/")
        end.reject(&:empty?)

        # Find first lesson url
        first_lesson = flat_items.find { |item| item['type'] == 'file' }
        first_lesson_url = first_lesson ? first_lesson['url'] : "#"

        site.config['curriculum'][subject_slug] = {
          'title' => tree['title'],
          'description' => description,
          'modules' => modules_list,
          'first_lesson_url' => first_lesson_url,
          'items' => flat_items
        }
      end

      # Compute the site-wide last updated date (most recent across all published notes)
      all_dates = pages_list.map { |item| item[:last_modified] }.compact
      if all_dates.any?
        latest = all_dates.max
        site.config['site_last_updated'] = latest.strftime('%B %-d, %Y')
        site.config['site_last_updated_iso'] = latest.strftime('%Y-%m-%d')
      end

      # Pass 2: Scan for links to build backlinks
      pages_list.each do |item|
        page = item[:page]
        source_title = item[:title]
        source_url = page.url
        content = page.content

        next unless content

        content.scan(/\[\[([^\]|]+)(?:\|([^\]]+))?\]\]/).each do |match|
          target = match[0].strip
          note_target, _heading = target.split('#', 2)
          note_target.strip!
          target_key = note_target.downcase

          if note_title_to_url[target_key]
            unless backlinks_map[target_key].any? { |bl| bl['url'] == source_url }
              backlinks_map[target_key] << {
                'title' => source_title,
                'url' => source_url
              }
            end
          end
        end
      end

      # Pass 3: Rewrite wikilinks and add to site pages
      pages_list.each do |item|
        page = item[:page]
        title_key = item[:title].downcase
        
        page.data['backlinks'] = backlinks_map[title_key]

        if page.content
          page.content.gsub!(/```dataview[\s\S]*?```/, "*[Dataview queries are only supported in Obsidian app]*")
          
          page.content.gsub!(/\[\[([^\]|]+)(?:\|([^\]]+))?\]\]/) do
            full_target = $1.strip
            display = $2 ? $2.strip : full_target
            
            note_target, heading = full_target.split('#', 2)
            note_target.strip!
            target_key = note_target.downcase
            
            anchor = heading ? "##{Jekyll::Utils.slugify(heading.strip)}" : ""
            
            resolved_url = note_title_to_url[target_key]
            if resolved_url
              "[#{display}]({{ \"#{resolved_url}\" | relative_url }}#{anchor})"
            else
              "<span class='offline-link' title='This note is private or not published'>#{display}</span>"
            end
          end
        end

        site.pages << page
      end
    end
  end
end
