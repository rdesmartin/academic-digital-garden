---
layout: page
title: My notes
permalink: /notes
---

<div class="papers">
    <ul>
        {% for note in site.notes %}
        <li><a href="{{ note.url }}">{{ note.title }}</a></li>
        {% endfor %}
    </ul>
</div>
