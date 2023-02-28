# frozen_string_literal: true

require_relative 'lib/basecamp/version'

Gem::Specification.new do |spec|
  spec.name = 'basecamp'
  spec.version = Basecamp::VERSION
  spec.authors = ['Igor Alexandrov']
  spec.email = ['igor.alexandrov@gmail.com']

  spec.summary = 'Ruby client for the Basecamp API'
  spec.description = 'Ruby client for the Basecamp API'
  spec.homepage = 'https://github.com/onetribe-team/basecamp'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/onetribe-team/basecamp'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(__dir__) do
      `git ls-files -z`.split("\x0").reject do |f|
        (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
      end
    end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'oauth2', '>= 1.4', '< 3'
  spec.add_dependency 'faraday', '~> 2.0'
  spec.add_development_dependency 'jetrockets-standard'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
