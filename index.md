---
layout: default
title: Dashboard
permalink: /
---

# CS Library

Welcome to the Computer Science Reference Library. This site is compiled directly from your Obsidian vault notes, maintaining the exact folder structure for easy reference, reading, and full-text search.

---

## Recently Published Pages

Below are the latest notes published to the site. Click on any page to open it.

{% assign sorted_pages = site.pages | sort: "url" %}
{% assign count = 0 %}
<ul class="backlinks-list" style="margin-top: 10px; margin-bottom: 30px;">
{% for p in sorted_pages %}
  {% if p.relative_path %}
    {% assign count = count | plus: 1 %}
    <li>
      <a href="{{ p.url | relative_url }}">{{ p.title }}</a>
      <span style="color: var(--text-muted); font-size: 0.85em; margin-left: 8px;">({{ p.url | split: '/' | slice: 0, -1 | join: ' / ' | remove_first: '/' }})</span>
    </li>
  {% endif %}
{% endfor %}
{% if count == 0 %}
  <li style="color: var(--text-muted); font-style: italic; list-style: none; padding-left: 0;">No pages published to the site yet. Add <code>published: true</code> to the frontmatter of any whitelisted note in your vault to display it here.</li>
{% endif %}
</ul>

---

## Library Subjects

Browse the core subject areas below:

<div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; margin-top: 15px;">
  {% for subject_item in site.curriculum %}
    {% assign subject_slug = subject_item[0] %}
    {% assign subject = subject_item[1] %}
    
    <div style="background-color: var(--bg-sidebar); border: 1px solid var(--border-color); border-radius: 6px; padding: 16px;">
      <h3 style="font-size: 1rem; font-weight: 600; color: var(--text-heading); margin-bottom: 8px; text-transform: capitalize;">
        {{ subject.title | replace: '-', ' ' }}
      </h3>
      <ul style="list-style-type: none; padding-left: 0; font-size: 0.88rem; line-height: 1.5;">
        {% for module_item in subject.modules %}
          {% assign module_name = module_item[0] %}
          <li style="color: var(--text-muted); margin-bottom: 4px;">
            <i class="fa fa-folder-open" style="font-size: 0.75rem; margin-right: 6px; opacity: 0.7;"></i>
            {{ module_name }}
          </li>
        {% endfor %}
      </ul>
    </div>
  {% endfor %}
</div>
