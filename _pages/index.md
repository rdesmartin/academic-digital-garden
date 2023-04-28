---
layout: page
title: Home
id: home
permalink: /
---

# Welcome! 🌱

<p style="padding: 3em 1em; background: #f5f7ff; border-radius: 4px;">
  Take a look at <span style="font-weight: bold">[[Your first note]]</span> to get started on your exploration.
</p>

This digital garden template has separate notes for academic papers, which are automatically generated from a BibTeX bibliography file. It is free, open source and the code is [on GitHub](https://github.com/rdesmartin/academic-digital-garden).

It is based on Maxime Vaillancourt's [great template](https://github.com/maximevaillancourt/digital-garden-jekyll-template) and the paper notes management was inspired by Alistair Reid's [RelatedWork website](https://github.com/alastairreid/RelatedWork)

The original [step-by-step guide explaining how to set this up from scratch](https://maximevaillancourt.com/blog/setting-up-your-own-digital-garden-with-jekyll) still applies and is the best way to get started.

<strong>Recently updated notes</strong>

<ul>
  {% assign recent_notes = site.notes | sort: "last_modified_at_timestamp" | reverse %}
  {% for note in recent_notes limit: 5 %}
    <li>
      {{ note.last_modified_at | date: "%Y-%m-%d" }} — <a class="internal-link" href="{{ note.url }}">{{ note.title }}</a>
    </li>
  {% endfor %}
</ul>

<strong>Recently added papers</strong>
<ul>
  {% assign recent_papers = site.papers | sort: "last_modified_at_timestamp" | reverse %}
  {% for paper in recent_papers limit: 5 %}
    <li>
      {{ paper.last_modified_at | date: "%Y-%m-%d" }} — <a class="internal-link" href="{{ paper.url }}">{{ paper.title }}</a>
    </li>
  {% endfor %}
</ul>

<style>
  .wrapper {
    max-width: 46em;
  }
</style>
