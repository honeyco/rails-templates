gem 'bootstrap-sass', github: 'thomas-mcdonald/bootstrap-sass', branch: '3'
gem 'slim-rails'
gem 'honey-cms'
gem 'honey-auth'
gem 'carrierwave'
gem 'fog'
gem 'aws-sdk'

run 'bundle install'

initializer 'carrierwave.rb', <<-CODE
CarrierWave.configure do |config|
  config.cache_dir = "\#{Rails.root}/tmp/"
  config.storage = :fog
  config.permissions = 0666
  config.fog_credentials = {
    provider:              'AWS',
    aws_access_key_id:     AWS.config.access_key_id,
    aws_secret_access_key: AWS.config.secret_access_key,
  }
  config.fog_directory = '#{app_name.underscore.dasherize}-production'
end
CODE

# require 'pry' ; binding.pry

run 'rm app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.slim', <<-CODE
doctype html
html
  head
    title #{app_name}
    = stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true
    = javascript_include_tag 'application', 'data-turbolinks-track' => true
    = csrf_meta_tags
  body
    = yield
CODE

run 'rm config/database.yml'
file 'config/database.yml', <<-CODE
development:
  adapter: postgresql
  database: #{app_name.underscore}_development
test:
  adapter: postgresql
  database: #{app_name.underscore}_test
CODE

run 'cp config/database.yml config/database.yml.example'
append_file '.gitignore', 'config/database.yml'

generate 'honey_auth:init'
generate 'cms:init'

rake 'db:create'
rake 'db:migrate'

generate 'cms:admin --email q.shanahan@gmail.com --password 123456'

route <<-CODE
HoneyAuth::Routes.new(self).draw
CMS::Routes.new(self).draw
root to: 'pages#home'
CODE

run 'rm app/assets/stylesheets/application.css'
file 'app/assets/stylesheets/application.css.scss', <<-CODE
/*
 *= require_self
 */

@import 'bootstrap';
CODE

run 'rm public/index.html'

git :init
git add: '.'
git commit: '-am init'
