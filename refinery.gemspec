# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{refinery}
  s.version = "0.9.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Anthony Eden"]
  s.date = %q{2009-06-29}
  s.description = %q{Process data in a distributed fashion.}
  s.email = %q{anthonyeden@gmail.com}
  s.executables = ["epub", "monitor", "pubnow", "refinery"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc",
     "README.textile"
  ]
  s.files = [
    ".autotest",
     ".gitignore",
     "CHANGELOG",
     "LICENSE",
     "README.rdoc",
     "README.textile",
     "Rakefile",
     "VERSION",
     "bin/epub",
     "bin/monitor",
     "bin/pubnow",
     "bin/refinery",
     "config/config.example.yml",
     "lib/refinery.rb",
     "lib/refinery/config.rb",
     "lib/refinery/configurable.rb",
     "lib/refinery/daemon.rb",
     "lib/refinery/event_publisher.rb",
     "lib/refinery/heartbeat.rb",
     "lib/refinery/loggable.rb",
     "lib/refinery/monitor.rb",
     "lib/refinery/publisher.rb",
     "lib/refinery/queueable.rb",
     "lib/refinery/server.rb",
     "lib/refinery/statistics.rb",
     "lib/refinery/stats_server.rb",
     "lib/refinery/utilities.rb",
     "lib/refinery/validations.rb",
     "lib/refinery/worker.rb",
     "logs/README",
     "publishers/error.rb",
     "publishers/sample.rb",
     "publishers/sleep.rb",
     "refinery.gemspec",
     "test/config.yml",
     "test/test_helper.rb",
     "test/unit/config_test.rb",
     "test/unit/configurable_test.rb",
     "test/unit/daemon_test.rb",
     "test/unit/event_publisher_test.rb",
     "test/unit/heartbeat_test.rb",
     "test/unit/loggable_test.rb",
     "test/unit/publisher_test.rb",
     "test/unit/queueable_test.rb",
     "test/unit/server_test.rb",
     "test/unit/statistics_test.rb",
     "test/unit/utilities_test.rb",
     "test/unit/validations_test.rb",
     "test/unit/worker_test.rb",
     "workers/error.rb",
     "workers/sample.rb",
     "workers/sleep.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/aeden/refinery}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{refinery}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Refinery processes data in a distributed environment.}
  s.test_files = [
    "test/test_helper.rb",
     "test/unit/config_test.rb",
     "test/unit/configurable_test.rb",
     "test/unit/daemon_test.rb",
     "test/unit/event_publisher_test.rb",
     "test/unit/heartbeat_test.rb",
     "test/unit/loggable_test.rb",
     "test/unit/publisher_test.rb",
     "test/unit/queueable_test.rb",
     "test/unit/server_test.rb",
     "test/unit/statistics_test.rb",
     "test/unit/utilities_test.rb",
     "test/unit/validations_test.rb",
     "test/unit/worker_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
