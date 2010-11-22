rvm gemset create wiki &&
rvm use 1.8.7@wiki &&
gem install bundler --no-rdoc --no-ri &&
bundle install &&
rake db:migrate &&
rake cucumber
