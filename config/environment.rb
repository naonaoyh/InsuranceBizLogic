require 'yaml'
path = "config/environment.yml"
APP_CONFIG = YAML.load_file(path)
RAILS_ROOT = "."
PRODUCTS_ROOT = "#{RAILS_ROOT}/public/git/products"
