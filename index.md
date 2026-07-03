---
layout: post
title: "Computer Science Reference Library"
permalink: /
---

Welcome to your **Computer Science Reference Library**—a custom-built digital curriculum designed to navigate core engineering subjects sequentially, just like a structured curriculum.

Select a learning path below to begin reading.

---

## 🚀 Choose a Learning Path

<div class="backlinks-grid" style="grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: 24px; margin-top: 25px;">

  <!-- Java Path Card -->
  <div class="backlink-card" style="padding: 24px; border-radius: 14px; position: relative; overflow: hidden; background: linear-gradient(180deg, var(--bg-card) 0%, rgba(99, 102, 241, 0.05) 100%);">
    <div style="font-size: 2rem; margin-bottom: 12px;">☕</div>
    <h3 style="font-size: 1.35rem; margin-top: 0; margin-bottom: 8px; color: var(--text-main);">Java Programming</h3>
    <p style="font-size: 0.92rem; color: var(--text-muted); margin-bottom: 24px; line-height: 1.5;">
      Master object-oriented design, JVM internals, garbage collection, concurrency primitives, and modern Java features.
    </p>
    <a href="{{ '/java-notes/concepts/basics/part-i/00-printing/' | relative_url }}" class="sidebar-home-link" style="display: inline-flex; justify-content: center; background: var(--gradient-primary); color: #fff; width: 100%;">
      Start Subject Curriculum &rarr;
    </a>
  </div>

  <!-- DSA Path Card -->
  <div class="backlink-card" style="padding: 24px; border-radius: 14px; position: relative; overflow: hidden; background: linear-gradient(180deg, var(--bg-card) 0%, rgba(168, 85, 247, 0.05) 100%);">
    <div style="font-size: 2rem; margin-bottom: 12px;">🌳</div>
    <h3 style="font-size: 1.35rem; margin-top: 0; margin-bottom: 8px; color: var(--text-main);">Data Structures & Algorithms</h3>
    <p style="font-size: 0.92rem; color: var(--text-muted); margin-bottom: 24px; line-height: 1.5;">
      Learn algorithmic complexity, sorting/searching, graph traversals, dynamic programming, and common coding patterns.
    </p>
    <a href="{{ '/dsa/notes/welcome/' | relative_url }}" class="sidebar-home-link" style="display: inline-flex; justify-content: center; background: var(--gradient-primary); color: #fff; width: 100%;">
      Start Subject Curriculum &rarr;
    </a>
  </div>

  <!-- System Design Card -->
  <div class="backlink-card" style="padding: 24px; border-radius: 14px; position: relative; overflow: hidden; background: linear-gradient(180deg, var(--bg-card) 0%, rgba(236, 72, 153, 0.05) 100%);">
    <div style="font-size: 2rem; margin-bottom: 12px;">🏗️</div>
    <h3 style="font-size: 1.35rem; margin-top: 0; margin-bottom: 8px; color: var(--text-main);">System Design</h3>
    <p style="font-size: 0.92rem; color: var(--text-muted); margin-bottom: 24px; line-height: 1.5;">
      Dive into load balancers, caching strategies, replication, relational/NoSQL sharding, and high availability systems.
    </p>
    <a href="{{ '/systemdesign-notes/system-design/' | relative_url }}" class="sidebar-home-link" style="display: inline-flex; justify-content: center; background: var(--gradient-primary); color: #fff; width: 100%;">
      Start Subject Curriculum &rarr;
    </a>
  </div>

  <!-- AI & ML Card -->
  <div class="backlink-card" style="padding: 24px; border-radius: 14px; position: relative; overflow: hidden; background: linear-gradient(180deg, var(--bg-card) 0%, rgba(59, 130, 246, 0.05) 100%);">
    <div style="font-size: 2rem; margin-bottom: 12px;">🧠</div>
    <h3 style="font-size: 1.35rem; margin-top: 0; margin-bottom: 8px; color: var(--text-main);">AI & Machine Learning</h3>
    <p style="font-size: 0.92rem; color: var(--text-muted); margin-bottom: 24px; line-height: 1.5;">
      Explore core machine learning equations, regression, neural networks, backpropagation, and large language models.
    </p>
    <a href="{{ '/ai-ml-notes/ai-research-areas/' | relative_url }}" class="sidebar-home-link" style="display: inline-flex; justify-content: center; background: var(--gradient-primary); color: #fff; width: 100%;">
      Start Subject Curriculum &rarr;
    </a>
  </div>

</div>

---

## ⚡ Interactive Search Mode
Press the <kbd class="search-kbd" style="font-size:0.85em;padding:2px 6px;">/</kbd> key or click the search box in the header to trigger the Command menu overlay. You can type keywords or use hashtag syntax (like `#java/core`) to instantly filter your digital garden.

---

## 📂 Active Note Index

Below is the directory map of the lessons currently compiled and published on this site.

{% assign sorted_pages = site.pages | sort: "url" %}
<ul style="margin-top: 15px; line-height: 1.8; list-style-type: square; padding-left: 20px;">
{% assign count = 0 %}
{% for p in sorted_pages %}
  {% if p.relative_path %}
    {% assign count = count | plus: 1 %}
    <li>
      <a href="{{ p.url | relative_url }}">{{ p.title }}</a>
      <span style="color: var(--text-muted); font-size: 0.85em; margin-left: 8px;">({{ p.url | split: '/' | slice: 1, 2 | join: ' &rarr; ' }})</span>
    </li>
  {% endif %}
{% endfor %}
{% if count == 0 %}
  <li style="color: var(--text-muted); font-style: italic;">No notes published to the site yet. Add <code>published: true</code> in the frontmatter of any whitelisted note in your vault to display it here!</li>
{% endif %}
</ul>
