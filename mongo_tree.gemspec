# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mongo_tree}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jim Mulhollnad"]
  s.date = %q{2009-04-18}
  s.description = %q{Add hierarchy tree functionality to MongoRecord (MongoDB) models.}
  s.email = %q{jim@squeejee.com}
  s.extra_rdoc_files = ["lib/mongo_tree.rb", "README.rdoc"]
  s.files = ["lib/mongo_tree.rb", "Rakefile", "README.rdoc", "Manifest", "mongo_tree.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/mully/mongo_tree}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Mongo_tree", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mongo_tree}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Add hierarchy tree functionality to MongoRecord (MongoDB) models.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
