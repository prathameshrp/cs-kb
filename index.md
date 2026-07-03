---
layout: post
title: "Computer Science Reference Library"
permalink: /
---

Welcome to the **Computer Science Reference Library**—a clean, searchable digital garden compiling core engineering concepts, design patterns, cheatsheets, and interview notes.

Use the sidebar navigation to browse topics, or use the search bar at the top-left to instantly query across all notes.

---

## 📚 Core Topics

<div class="backlinks-grid" style="grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; margin-top: 20px;">

  <div class="backlink-card" style="padding: 20px;">
    <div class="backlink-title" style="font-size: 1.2em; margin-bottom: 8px;">
      ☕ Java Programming
    </div>
    <div class="backlink-meta" style="font-size: 0.9em; line-height: 1.4;">
      Deep dive into the JVM, language specs, modern features, and interview Q&As.
      <br><br>
      <a href="{{ '/notes/Java-Notes/01 - Concepts/L0 Basics/PART I/00 - Printing.html' | relative_url }}">Start Learning &rarr;</a>
    </div>
  </div>

  <div class="backlink-card" style="padding: 20px;">
    <div class="backlink-title" style="font-size: 1.2em; margin-bottom: 8px;">
      🌳 Data Structures & Algorithms
    </div>
    <div class="backlink-meta" style="font-size: 0.9em; line-height: 1.4;">
      Core DSA patterns, complexity analysis, and solved coding interview problems.
      <br><br>
      <a href="{{ '/notes/DSA/DSA-Notes/Welcome.html' | relative_url }}">Start Learning &rarr;</a>
    </div>
  </div>

  <div class="backlink-card" style="padding: 20px;">
    <div class="backlink-title" style="font-size: 1.2em; margin-bottom: 8px;">
      🏗️ System Design
    </div>
    <div class="backlink-meta" style="font-size: 0.9em; line-height: 1.4;">
      High-level and low-level design patterns, system scaling, and distributed architecture.
      <br><br>
      <a href="{{ '/notes/SystemDesign-Notes/README.html' | relative_url }}">Start Learning &rarr;</a>
    </div>
  </div>

  <div class="backlink-card" style="padding: 20px;">
    <div class="backlink-title" style="font-size: 1.2em; margin-bottom: 8px;">
      🧠 AI & Machine Learning
    </div>
    <div class="backlink-meta" style="font-size: 0.9em; line-height: 1.4;">
      Notes on machine learning algorithms, deep learning models, and data science foundations.
      <br><br>
      <a href="{{ '/notes/AI-ML-Notes/README.html' | relative_url }}">Start Learning &rarr;</a>
    </div>
  </div>

  <div class="backlink-card" style="padding: 20px;">
    <div class="backlink-title" style="font-size: 1.2em; margin-bottom: 8px;">
      ☁️ Cloud & DevOps
    </div>
    <div class="backlink-meta" style="font-size: 0.9em; line-height: 1.4;">
      SRE principles, CI/CD pipelines, containerization (Docker, K8s), and cloud platforms.
      <br><br>
      <a href="{{ '/notes/Cloud-Notes/README.html' | relative_url }}">Start Learning &rarr;</a>
    </div>
  </div>

  <div class="backlink-card" style="padding: 20px;">
    <div class="backlink-title" style="font-size: 1.2em; margin-bottom: 8px;">
      🌐 Networking & Systems
    </div>
    <div class="backlink-meta" style="font-size: 0.9em; line-height: 1.4;">
      Operating systems internals, network protocols, UNIX syscalls, and low-level engineering.
      <br><br>
      <a href="{{ '/notes/Networks-Notes/README.html' | relative_url }}">Start Learning &rarr;</a>
    </div>
  </div>

</div>

---

## ⚡ Quick Search Tip
Press `S` or click the search input in the sidebar to open the instant search. You can search for code snippets, terms (like `garbage collection` or `concurrency`), and tags (like `#java/core`).

---

## 🌱 Recent Notes
Below is a full catalog of notes currently published to the site.

{% assign sorted_pages = site.pages | sort: "url" %}
<ul style="margin-top: 15px; line-height: 1.7;">
{% for p in sorted_pages %}
  {% if p.url contains '/notes/' %}
    <li>
      <a href="{{ p.url | relative_url }}">{{ p.title }}</a>
      <span style="color: #8c8c8c; font-size: 0.85em; margin-left: 8px;">({{ p.relative_dir }})</span>
    </li>
  {% endif %}
{% endfor %}
</ul>
