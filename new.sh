function generate-rails-app {
  rails new $1 -m template.rb -j -d postgresql -f
}
