spec = Gem::Specification.new do |s|
  s.name = 'refinery'
  s.version = '0.9.0'
  s.summary = "Refinery processes data in a distributed environment."
  s.description = %{Process data in a distributed fashion.}
  s.files = [
    Dir['bin/**/*'],
    Dir['config/config.example.yml'],
    Dir['docs/**/*'],
    Dir['lib/**/*.rb'],
    'logs',
    'publishers',
    'Rakefile',
    'README.rdoc',
    'README.textile',
    'LICENSE',
    'CHANGELOG',
    Dir['test/**/*.rb'],
    'workers',
  ].flatten
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.executables = ['refinery','epub','pubnow','monitor']
  s.has_rdoc = true
  s.extra_rdoc_files = Dir['[A-Z]*']
  s.rdoc_options << '--title' <<  'Refinery - Distributed Processing'
  s.author = "Anthony Eden"
  s.email = "anthonyeden@gmail.com"
  s.homepage = 'http://github.com/aeden/refinery'
  s.rubyforge_project = 'refinery'
end
