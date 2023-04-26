---
layout: page
title: Papers
permalink: /papers
---

<div class="papers">
    <ul>
        {% for paper in site.papers %}
            <li><a href="{{ paper.url }}">{{ paper.title }}</a></li>
        {% endfor %}
    </ul>
</div>
