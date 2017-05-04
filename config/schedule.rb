# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# loading our environment variables and defaults
require 'yaml'
require 'time'
require 'tzinfo'

path = "/var/www/logan-#{rails_env}/current/"

env_file = "#{path}/config/local_env.yml"
defaults = "#{path}/config/sample.local_env.yml"

YAML.load(File.open(env_file)).each do |key, value|
  ENV[key.to_s] = value if ENV[key.to_s].nil?
end if File.exist?(env_file)

# load in defaults unless they are already set
YAML.load(File.open(defaults)).each do |key, value|
  ENV[key.to_s] = value if ENV[key.to_s].nil?
end

# run our jobs in the right time zone
set :job_template, "TZ=\"#{ENV['TIME_ZONE']}\" bash -l -c ':job'"
set :output, "#{path}/log/cron_log.log"
#

every 30.minutes do
  command "backup perform --trigger my_backup -r #{path}/Backup/"
end

# https://coderwall.com/p/ahdolq/local-timezone-fix-for-whenever-gem
# see: https://github.com/javan/whenever/pull/239
# time should be > 03:00
def local_time(time)
  TZInfo::Timezone.get(ENV['TIME_ZONE']).local_to_utc(Time.parse(time))
end

# this queues up all the email/sms for the day!
every :day, at: local_time("8:00am") do
  runner "User.send_all_reminders"
  runner "Person.send_all_reminders"
end

every :day, at: local_time("2:00am") do
  command "cd #{path} && bundle exec #{path}/bin/delayed_job restart"
end

every :reboot do
  command "cd #{path} && #{path}/bin/unicorn_rails -c config/unicorn.rb -E #{ENV['RAILS_ENV']} -D "
  command "cd #{path} && bundle exec #{path}/bin/delayed_job start"
end
#
# every 4.days do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
