# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new

require 'rake/extensiontask'

task build: :compile # rubocop:disable Rake/Desc

desc 'Run clang-format'
task 'clang-format' do
  sh 'clang-format -style=file -Werror --dry-run ext/magro/*.c ext/magro/*.h'
end

Rake::ExtensionTask.new('magro') do |ext|
  ext.lib_dir = 'lib/magro'
end

task default: %i[clobber compile rubocop spec]
