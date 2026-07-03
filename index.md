---
layout: default
title: Dashboard
permalink: /
---

<div style="margin-bottom: 36px; padding-bottom: 24px; border-bottom: 1px solid var(--border-color);">
  <h1 style="font-family: var(--font-serif); font-size: 2rem; font-weight: 600; color: var(--text-heading); margin-bottom: 10px;">CS Library</h1>
  <p style="font-size: 1rem; color: var(--text-muted); line-height: 1.6; max-width: 520px; margin-bottom: 10px;">Structured notes on Computer Science fundamentals. From basics to advanced topics. Built for long-term reference.</p>
  {% if site.site_last_updated %}
  <p style="font-size: 0.8rem; color: var(--text-muted); display: flex; align-items: center; gap: 6px;">
    <i class="fa-regular fa-clock" style="font-size: 0.75rem;"></i>
    Last updated: <time datetime="{{ site.site_last_updated_iso }}">{{ site.site_last_updated }}</time>
  </p>
  {% endif %}
</div>

<!-- Recently Visited (Client-side, hidden until pages read) -->
<div id="recently-visited-section" style="display: none; margin-bottom: 32px;">
  <h3 style="font-size: 0.75rem; font-weight: 700; letter-spacing: 0.07em; text-transform: uppercase; color: var(--text-muted); margin-bottom: 12px;">
    Continue Reading
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
        <li>
          <a href="${item.url}" style="font-size: 0.88rem; font-weight: 500; color: var(--text-link); text-decoration: none; display: flex; align-items: center; gap: 8px;">
            <i class="fa-regular fa-file-lines" style="font-size: 0.78rem;"></i>
            ${item.title}
          </a>
        </li>
      `).join('');
    }
  })();
</script>

## Subjects

<div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 16px; margin-top: 16px; margin-bottom: 40px;">

  {% for subject_item in site.curriculum %}
    {% assign subject_slug = subject_item[0] %}
    {% assign subject = subject_item[1] %}

    <a href="{{ subject.first_lesson_url | relative_url }}" style="text-decoration: none !important; display: block; background-color: var(--bg-sidebar); border: 1px solid var(--border-color); border-radius: 6px; padding: 18px 20px; transition: border-color 0.2s, background-color 0.2s;" onmouseover="this.style.borderColor='#8b949e'; this.style.backgroundColor='var(--bg-hover)';" onmouseout="this.style.borderColor='var(--border-color)'; this.style.backgroundColor='var(--bg-sidebar)';">
      <h3 style="font-family: var(--font-serif); font-size: 1.05rem; font-weight: 600; color: var(--text-heading); margin-bottom: 8px; text-transform: capitalize;">
        {{ subject_slug | replace: '-notes', '' | replace: '-', ' ' | strip }}
      </h3>
      <p style="font-size: 0.82rem; color: var(--text-muted); line-height: 1.5; margin-bottom: 14px;">
        {{ subject.description | truncate: 120 }}
      </p>
      <div style="font-size: 0.75rem; color: var(--text-muted); display: flex; align-items: center; gap: 6px;">
        <i class="fa-regular fa-folder"></i>
        {{ subject.modules | size }} module{% if subject.modules.size != 1 %}s{% endif %} published
      </div>
    </a>
  {% endfor %}

</div>

---

## Recently Published

{% assign sorted_pages = site.pages | sort: "url" %}
{% assign count = 0 %}
<ul style="margin-top: 12px; margin-bottom: 30px; list-style: none; padding: 0; display: flex; flex-direction: column; gap: 8px;">
{% for p in sorted_pages %}
  {% if p.relative_path %}
    {% assign count = count | plus: 1 %}
    <li style="display: flex; align-items: baseline; gap: 10px; font-size: 0.88rem;">
      <i class="fa-regular fa-file-lines" style="color: var(--text-muted); font-size: 0.78rem; flex-shrink: 0;"></i>
      <span>
        <a href="{{ p.url | relative_url }}" style="font-weight: 500; color: var(--text-link);">{{ p.title }}</a>
        <span style="color: var(--text-muted); margin-left: 8px; font-size: 0.8em;">{{ p.url | split: '/' | slice: 1, 99 | join: ' / ' | remove_last: ' / ' }}</span>
      </span>
    </li>
  {% endif %}
{% endfor %}
{% if count == 0 %}
  <li style="color: var(--text-muted); font-style: italic; font-size: 0.9rem;">No pages published yet. Add <code>published: true</code> to the frontmatter of any note to list it here.</li>
{% endif %}
</ul>
