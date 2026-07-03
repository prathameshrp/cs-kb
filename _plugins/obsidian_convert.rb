require 'find'
require 'yaml'
require 'fileutils'

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
      
      # Set permalink explicitly to have subject/category/note-name without .html suffix
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

    def self.clean_segment(segment)
      # Clean up numbers and patterns: "01 - Concepts" -> "Concepts", "L0 Basics" -> "Basics"
      clean = segment.sub(/\A(?:\d+\s*-\s*|L\d+\s+|PART\s+[I|V|X]+\s*-*\s*)/i, '')
      clean.strip
    end

    def self.slugify(str)
      str.downcase.strip.gsub(/[^a-z0-9]+/, '-')
    end

    def self.make_permalink(rel_path)
      parts = rel_path.split('/')
      subject = slugify(clean_segment(parts[0]))
      
      middle_slugs = parts[1...-1].map do |seg|
        slugify(clean_segment(seg))
      end.reject(&:empty?)
      
      filename_slug = slugify(File.basename(parts.last, ".md"))
      
      if middle_slugs.empty?
        "/#{subject}/#{filename_slug}/"
      else
        "/#{subject}/#{middle_slugs.join('/')}/#{filename_slug}/"
      end
    end

    def generate(site)
      notes_dir = File.join(site.source, '_notes')
      unless Dir.exist?(notes_dir)
        Jekyll.logger.warn "ObsidianConverter:", "_notes directory does not exist at #{notes_dir}!"
        return
      end

      whitelist_prefixes = [
        "Java-Notes/01 - Concepts/",
        "Java-Notes/02 - Patterns/",
        "Java-Notes/03 - Questions/",
        "Java-Notes/04 - Cheatsheets/",
        "DSA/DSA-Notes/",
        "AI-ML-Notes/",
        "Cloud-Notes/",
        "DevOps-SRE-Notes/",
        "Networks-Notes/",
        "OS-Systems-Notes/",
        "SystemDesign-Notes/",
        "WebDev-Notes/",
        "Data-Science-Notes/"
      ]

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

        # Read the file's frontmatter to check if published is explicitly true
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
        subject_slug = self.class.slugify(self.class.clean_segment(parts[0]))
        subject_title = self.class.clean_segment(parts[0])
        
        # Determine Module Name (clean name of first directory under the subject)
        module_name = parts.size > 2 ? self.class.clean_segment(parts[1]) : "General"
        
        permalink = self.class.make_permalink(rel_path)
        clean_name = File.basename(rel_path, ".md")
        
        # Map note names to their clean URL path (resolved for wikilinks)
        note_title_to_url[clean_name] = permalink
        note_title_to_url[clean_name.downcase] = permalink
        note_title_to_title[clean_name.downcase] = clean_name
        
        notes_metadata << {
          path: note_path,
          dir: File.dirname(permalink),
          name: "#{clean_name}.md",
          relative_dir: File.dirname(rel_path),
          title: clean_name,
          permalink: permalink,
          subject_slug: subject_slug,
          subject_title: subject_title,
          module_name: module_name
        }
      end

      # Sort all notes by their path before creating Pages to ensure sequential ordering
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
        
        pages_list << { 
          page: page, 
          title: page.data['title'], 
          path: note[:path],
          subject_slug: note[:subject_slug],
          subject_title: note[:subject_title],
          module_name: note[:module_name]
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

      # Build curriculum outline for sidebar
      site.config['curriculum'] = {}
      notes_by_subject.each do |subject_slug, list|
        subject_title = list.first[:subject_title]
        
        modules = {}
        list.each do |item|
          mod_name = item[:module_name]
          modules[mod_name] ||= []
          modules[mod_name] << {
            'title' => item[:title],
            'url' => item[:page].url
          }
        end
        
        site.config['curriculum'][subject_slug] = {
          'title' => subject_title,
          'modules' => modules
        }
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
