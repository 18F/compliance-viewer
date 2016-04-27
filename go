#! /usr/bin/env ruby

require 'English'

Dir.chdir File.dirname(__FILE__)

def try_command_and_restart(command)
  exit $CHILD_STATUS.exitstatus unless system command
  exec({ 'RUBYOPT' => nil }, RbConfig.ruby, *[$PROGRAM_NAME].concat(ARGV))
end

begin
  require 'bundler/setup' if File.exist? 'Gemfile'
rescue LoadError
  try_command_and_restart 'gem install bundler'
rescue SystemExit
  try_command_and_restart 'bundle install'
end

begin
  require 'go_script'
rescue LoadError
  try_command_and_restart 'gem install go_script' unless File.exist? 'Gemfile'
  abort "Please add \"gem 'go_script'\" to your Gemfile"
end

extend GoScript
check_ruby_version '2.2.3'

command_group :dev, 'Development commands'

def_command :init, 'Set up the development environment' do
end

def_command :update_gems, 'Update Ruby gems' do |gems|
  update_gems gems
end

def_command :test, 'Execute automated tests' do |args|
  exec_cmd "bundle exec rspec #{args.join ' '}"
end

def_command :lint, 'Run style-checking tools' do |files|
  files = files.group_by { |f| File.extname f }
  lint_ruby files['.rb'] # uses rubocop
  lint_javascript Dir.pwd, files['.js'] # uses node_modules/jshint
end

<<<<<<< af10b3d3c5ee4de1388c8d9327542e54b7fbb215
def_command :update_cg_style, 'Update cloudgov_styles' do
  vendor_dir = './public/vendor'
  exec_cmd "npm install"
  exec_cmd "rm -rf #{vendor_dir}"
  exec_cmd "mkdir #{vendor_dir}"
  %w(js css img).each do |val|
    exec_cmd "cp -R ./node_modules/cloudgov-style/#{val} #{vendor_dir}/"
  end
  exec_cmd "cp -R ./node_modules/cloudgov-style/font/ #{vendor_dir}/fonts"
end

def_command :test_ci, 'update styles and then run the tests' do |args|
  update_cg_style
  test args
end

=======
>>>>>>> Removing cloud.gov styles update script for MVP.
execute_command ARGV
