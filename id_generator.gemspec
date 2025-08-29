# frozen_string_literal: true

require_relative 'lib/id_generator'

Gem::Specification.new do |spec|
  spec.name          = 'idGenerator'
  spec.version       = IdGenerator::VERSION
  spec.authors       = ['Fred']
  spec.email         = ['archmagosgit@outlook.com']

  spec.summary       = 'A simple ID generator with color assignment functionality'
  spec.description   = 'Generates secure 8-character IDs based on IP addresses and context, with daily ID support and color assignment for poster IDs'
  spec.homepage      = 'https://github.com/archmagos/id-generator'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6.0'

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rake', '~> 13.0'
end
