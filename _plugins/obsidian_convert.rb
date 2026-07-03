require 'find'
require 'yaml'
require 'fileutils'

module Jekyll
  class ObsidianPage < Page
    def initialize(site, base, dir, name, note_path, relative_dir)
      @site = site
      @base = base
      @dir = dir
      @name = name

      self.process(name)
      self.read_yaml(File.dirname(note_path), File.basename(note_path))

      self.data['layout'] ||= 'post'
      
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

      # Pass 1: Scan and identify all whitelisted notes, extract titles and URLs (ONLY if published: true)
      Dir.glob(File.join(notes_dir, "**/*.md")).each do |note_path|
        rel_path = note_path.sub("#{notes_dir}/", "")
        is_whitelisted = whitelist_prefixes.any? { |prefix| rel_path.start_with?(prefix) }
        next unless is_whitelisted
        
        # Skip templates, daily notes, and attachments globally (case-insensitive)
        next if rel_path.downcase.include?("template") || rel_path.downcase.include?("daily") || rel_path.downcase.include?("attachment")

        # Read the file's frontmatter to check if published is explicitly true
        begin
          content_str = File.read(note_path)
          if content_str =~ /\A(---\s*\n[\s\S]*?\n---\s*\n)/
            frontmatter = YAML.safe_load($1, permitted_classes: [Date, Time])
            # Skip if published is not explicitly set to true
            next unless frontmatter && (frontmatter['published'] == true || frontmatter['published'] == "true")
          else
            next # No frontmatter, skip
          end
        rescue => e
          Jekyll.logger.error "ObsidianConverter:", "Error reading frontmatter for #{note_path}: #{e.message}"
          next
        end

        basename = File.basename(note_path, ".md")
        clean_dir = File.dirname(rel_path)
        clean_name = File.basename(rel_path, ".md")
        
        url_dir = "/notes/#{clean_dir}"
        relative_url = "#{url_dir}/#{clean_name}.html"
        
        note_title_to_url[clean_name] = relative_url
        note_title_to_url[clean_name.downcase] = relative_url
        note_title_to_title[clean_name.downcase] = clean_name
        
        notes_metadata << {
          path: note_path,
          dir: url_dir,
          name: "#{clean_name}.md",
          relative_dir: clean_dir,
          title: clean_name
        }
      end

      Jekyll.logger.info "ObsidianConverter:", "Found #{notes_metadata.size} published notes."

      # Initialize backlinks map
      backlinks_map = Hash.new { |h, k| h[k] = [] }
      pages_list = []

      notes_metadata.each do |note|
        page = ObsidianPage.new(site, site.source, note[:dir], note[:name], note[:path], note[:relative_dir])
        
        page.data['title'] ||= note[:title]
        title_key = page.data['title'].downcase
        
        pages_list << { page: page, title: page.data['title'], path: note[:path] }
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

      # Pass 3: Rewrite content and add pages to site
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
