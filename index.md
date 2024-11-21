---
layout: default
---
{% for post in site.posts %}
<a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a>
<small>{{ post.date | date: "%B %d, %Y" }}</small>
{% endfor %}
{{post.myiframe}}
