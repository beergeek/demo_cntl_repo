source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 4.4.0'
  gem "rspec"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppetlabs_spec_helper"
  gem "onceover", :git =>  'https://github.com/beergeek/onceover.git', :branch => 'shared_examples'
end

group :pre do
  gem "puppet-lint"
end
