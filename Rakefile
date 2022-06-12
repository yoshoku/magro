# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rake/extensiontask'

task build: :compile

Rake::ExtensionTask.new('magro') do |ext|
  ext.lib_dir = 'lib/magro'
end

task default: %i[clobber compile spec]
