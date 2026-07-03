---
layout: default
title: Dashboard
permalink: /
---

# Computer Science Reference Library

Hi, I'm Prathamesh. Welcome to my digital computer science library. This is where I compile my atomic study notes, interview preparation guides, and real-world reference logs. The subjects here represent structured self-study curriculums, built directly out of my private Obsidian notes vault.

---

<!-- Recently Visited Pages Section (Dynamic Client-side LocalStorage) -->
<div id="recently-visited-section" style="display: none; margin-bottom: 35px; background-color: var(--bg-sidebar); border: 1px solid var(--border-color); border-radius: 6px; padding: 16px 20px;">
  <h3 style="font-family: var(--font-serif); font-size: 1.1rem; font-weight: 600; color: var(--text-heading); margin-bottom: 12px; display: flex; align-items: center; gap: 8px;">
    <i class="fa-regular fa-clock" style="color: var(--text-link);"></i> Recently Visited Pages
  </h3>
  <ul id="recently-visited-list" style="list-style: none; padding-left: 0; display: flex; flex-direction: column; gap: 6px;"></ul>
</div>

<script>
  (function() {
    const history = JSON.parse(localStorage.getItem('cs_lib_visited') || '[]');
    const container = document.getElementById('recently-visited-section');
    const list = document.getElementById('recently-visited-list');
    if (history.length > 0 && container && list) {
      container.style.display = 'block';
      list.innerHTML = history.map(item => `
        <li style="font-size: 0.88rem;">
          <a href="${item.url}" style="font-weight: 500; color: var(--text-link); text-decoration: none;">
            ${item.title}
          </a>
          <span style="color: var(--text-muted); font-size: 0.8em; margin-left: 8px;">
            ${item.url.split('/').slice(2, -1).join(' / ')}
          </span>
        </li>
      `).join('');
    }
  })();
</script>

---

## Library Subjects

Select a subject path to view the documentation structure and start learning:

<div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 20px; margin-top: 20px; margin-bottom: 40px;">

  {% for subject_item in site.curriculum %}
    {% assign subject_slug = subject_item[0] %}
    {% assign subject = subject_item[1] %}
    
    <div style="background-color: var(--bg-sidebar); border: 1px solid var(--border-color); border-top: 3px solid #389fff; border-radius: 6px; padding: 20px; display: flex; flex-direction: column; justify-content: space-between;">
      <div>
        <h3 style="font-family: var(--font-serif); font-size: 1.25rem; font-weight: 600; color: var(--text-heading); margin-bottom: 8px; text-transform: capitalize;">
          {{ subject_slug | replace: '-', ' ' }}
        </h3>
        <p style="font-size: 0.85rem; color: var(--text-muted); line-height: 1.5; margin-bottom: 16px;">
          {{ subject.description }}
        </p>
        
        <div style="font-size: 0.82rem; margin-bottom: 20px;">
          <div style="color: var(--text-heading); font-weight: 600; margin-bottom: 6px; font-size: 0.75rem; letter-spacing: 0.05em; text-transform: uppercase;">Syllabus Directory:</div>
          <ul style="list-style: none; padding-left: 0; display: flex; flex-direction: column; gap: 4px;">
            {% for mod in subject.modules %}
              <li style="color: var(--text-muted);"><i class="fa-regular fa-folder" style="margin-right: 6px; font-size: 0.8rem;"></i> {{ mod }}</li>
            {% endfor %}
          </ul>
        </div>
      </div>
      
      <a href="{{ subject.first_lesson_url | relative_url }}" style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; width: 100%; text-align: center; background-color: var(--bg-hover); border: 1px solid var(--border-color); color: var(--text-heading); padding: 8px; border-radius: 4px; font-size: 0.85rem; font-weight: 500; transition: background-color 0.2s;" onmouseover="this.style.backgroundColor='var(--bg-hover)'" onmouseout="this.style.backgroundColor='transparent'">
        Start Reading <i class="fa-solid fa-arrow-right"></i>
      </a>
    </div>
  {% endfor %}

</div>

---

## Recently Published Pages

Below are the latest notes updated in your vault:

{% assign sorted_pages = site.pages | sort: "url" %}
{% assign count = 0 %}
<ul style="margin-top: 15px; margin-bottom: 30px; line-height: 1.8; list-style-type: square; padding-left: 20px;">
{% for p in sorted_pages %}
  {% if p.relative_path %}
    {% assign count = count | plus: 1 %}
    <li>
      <a href="{{ p.url | relative_url }}" style="font-weight: 500;">{{ p.title }}</a>
      <span style="color: var(--text-muted); font-size: 0.85em; margin-left: 8px;">({{ p.url | split: '/' | slice: 0, -1 | join: ' / ' | remove_first: '/' }})</span>
    </li>
  {% endif %}
{% endfor %}
{% if count == 0 %}
  <li style="color: var(--text-muted); font-style: italic; list-style: none; padding-left: 0;">No pages published to the site yet. Add <code>published: true</code> to the frontmatter of any whitelisted note in your vault to display it here.</li>
{% endif %}
</ul>
