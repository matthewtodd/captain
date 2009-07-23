this_rakefile_uses_shoe = <<END
----------------------------------------
Please install Shoe:
gem sources --add http://gems.github.com
gem install matthewtodd-shoe
----------------------------------------
END

begin
  gem 'matthewtodd-shoe'
rescue Gem::LoadError
  abort this_rakefile_uses_shoe
else
  require 'shoe'
end

Shoe.tie('captain', '0.1.0', 'Captain loots apt repositories to build an custom installer CD. Yarr.') do |spec|
  spec.add_development_dependency 'cucumber'
end
