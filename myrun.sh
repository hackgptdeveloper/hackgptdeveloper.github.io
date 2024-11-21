docker run -p 4000:4000 -v $(pwd):/site bretfisher/jekyll-serve

exit

bundle update
bundle update <THEME>


Gem-based themes make it easier for theme developers to make updates available to anyone who has the theme gem. When there’s an update, theme developers push the update to RubyGems.

If you have the theme gem, you can (if you desire) run bundle update to update all gems in your project. Or you can run bundle update <THEME>, replacing <THEME> with the theme name, such as minima, to just update the theme gem. Any new files or updates the theme developer has made (such as to stylesheets or includes) will be pulled into your project automatically.

The goal of gem-based themes is to allow you to get all the benefits of a robust, continually updated theme without having all the theme’s files getting in your way and over-complicating what might be your primary focus: creating content.
