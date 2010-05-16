TEST_DIR = File.join(File.dirname(__FILE__))
TEST_TMP_DIR = File.join(TEST_DIR, 'tmp')

$:.unshift(File.join(TEST_DIR, '../lib'))

# Setup
require 'test/unit'
require 'rubygems'
begin; require 'turn'; rescue LoadError; end # I like this gem for test result output

require 'active_support'
require 'active_record'
require 'active_record/fixtures'

require 'ruby-debug'
Debugger.settings[:autoeval] = true
Debugger.start

config = YAML::load(IO.read(File.join(TEST_DIR, '/database.yml')))

ActiveRecord::Base.configurations = config
ActiveRecord::Base.logger = Logger.new(File.join(TEST_TMP_DIR, 'test.log'))
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

begin
  require 'factory_girl'
  require 'test/factories'
  rescue LoadError
end

load(File.join(TEST_DIR, 'schema.rb'))
require File.join(TEST_DIR, '../init')
