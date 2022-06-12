# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'magro/version'

Gem::Specification.new do |spec|
  spec.name          = 'magro'
  spec.version       = Magro::VERSION
  spec.authors       = ['yoshoku']
  spec.email         = ['yoshoku@outlook.com']

  spec.summary       = 'Magro is a minimal image processing library for Ruby.'
  spec.description   = <<~MSG
    Magro is a minimal image processing library for Ruby.
    Magro uses Numo::NArray arrays as image objects and provides basic image processing functions.
    Current supporting features are reading and writing JPEG and PNG images,
    image resizing with bilinear interpolation method, and image filtering.
  MSG

  spec.homepage      = 'https://github.com/yoshoku/magro'
  spec.license       = 'BSD-3-Clause'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/yoshoku/magro'
  spec.metadata['changelog_uri'] = 'https://github.com/yoshoku/magro/blob/main/CHANGELOG.md'
  spec.metadata['documentation_uri'] = 'https://yoshoku.github.io/magro/doc/'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(bin|test|spec|features|sig-deps)/}) }
                     .select { |f| f.match(/\.(?:rb|rbs|h|c|md|txt)$/) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions    = ['ext/magro/extconf.rb']

  spec.add_runtime_dependency 'numo-narray', '>= 0.9.1'
end
