spec = Gem::Specification.new do |s|
  s.name = 'refinery'
  s.version = '0.1'
  s.summary = "Refinery processes data in a distributed environment."
  s.description = %{Process data in a distributed fashion.}
  s.files = [
    Dir['lib/**/*.rb'],
    Dir['test/**/*.rb'],
    Dir['docs/**/*'],
    Dir['bin/**/*'],
    Dir['config/config.example.yml'],
    'logs',
    'publishers',
    'workers',
    'README.rdoc',
    'README.textile'
  ].flatten
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.executables = ['refinery','epub']
  s.has_rdoc = true
  s.extra_rdoc_files = Dir['[A-Z]*']
  s.rdoc_options << '--title' <<  'Refinery - Distributed Processing'
  s.author = "Anthony Eden"
  s.email = "anthonyeden@gmail.com"
  s.homepage = 'http://anthonyeden.com/projects/refinery'
  s.rubyforge_project = 'refinery'
end
