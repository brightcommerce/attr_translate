require "./lib/attr_translate/version"

Gem::Specification.new do |gem|
  gem.name        = "attr_translate"
  gem.version     = AttrTranslate::Version::Compact
  gem.summary     = AttrTranslate::Version::Summary
  gem.description = AttrTranslate::Version::Description
  gem.authors     = AttrTranslate::Version::Author
  gem.email       = AttrTranslate::Version::Email
  gem.homepage    = AttrTranslate::Version::Homepage
  gem.license     = AttrTranslate::Version::License
  gem.metadata    = AttrTranslate::Version::Metadata
  gem.platform    = Gem::Platform::RUBY

  gem.required_ruby_version = '>= 2.3'
  gem.require_paths = ["lib"]
  gem.files = Dir[
    "{lib}/**/*",
    "MIT-LICENSE",
    "CHANGELOG.md",
    "README.md"
  ]

  gem.add_runtime_dependency 'activerecord', '>= 5.1.4'
  gem.add_runtime_dependency 'activesupport', '>= 5.1.4'
end
