
git config --global user.name "hackgptdeveloper"
git config --global user.email "hackgptdeveloper@gmail.com"
git config --global credential.helper store

exit
docker run -p 4000:4000 -v $(pwd):/site bretfisher/jekyll-serve
