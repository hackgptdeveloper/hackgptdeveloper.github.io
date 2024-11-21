---
layout: default
---
{% for post in site.posts %}
<a href="{{ site.baseurl }}{{ post.url }}">{{ post.url }}</a>
<small>{{ post.date | date: "%B %d, %Y" }}</small>
{% endfor %}
{{post.myiframe}}
