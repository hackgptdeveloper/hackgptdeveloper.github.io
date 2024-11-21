---
layout: default
---

        {% for post in site.posts %}
        <h6>
            <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a>
            <small>{{ post.date | date: "%B %d, %Y" }}</small>
        </h6>
        {% endfor %}
        {{post.myiframe}}



<h3>  {{ page.title }} </h3>

<div id="categories">
{% for category in site.categories %}
  <div class="category-box" >
    {% capture category_name %}{{ category | first }}{% endcapture %}
    <div id="#{{ category_name | slugize }}"></div>
    <h4 class="category-head"><a href="{{ site.baseurl }}/blog/categories/{{ category_name }}">{{ category_name }}</a></h4>
    <a name="{{ category_name | slugize }}"></a>
     {% for post in site.categories[category_name] %}
      <a href="{{ site.baseurl }}{{ post.url }}">{{post.title}}</a>


    {% endfor %}

  </div>
{% endfor %}
</div>


