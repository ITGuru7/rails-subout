# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "pubnub-ruby"
  s.version = "3.3.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["PubNub"]
  s.date = "2012-09-18"
  s.description = "Ruby anywhere in the world in 250ms with PubNub!"
  s.email = "support@pubnub.com"
  s.homepage = "http://github.com/pubnub/pubnub-api"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "PubNub Official Ruby gem"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<eventmachine>, ["~> 1.0"])
      s.add_runtime_dependency(%q<uuid>, ["~> 2.3.5"])
      s.add_runtime_dependency(%q<yajl-ruby>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<eventmachine>, ["~> 0.1.0"])
      s.add_dependency(%q<uuid>, ["~> 2.3.5"])
      s.add_dependency(%q<yajl-ruby>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<eventmachine>, ["~> 0.1.0"])
    s.add_dependency(%q<uuid>, ["~> 2.3.5"])
    s.add_dependency(%q<yajl-ruby>, [">= 0"])
  end
end
