# run Wiki god with: god --log-level=info -c config/wiki.god -l god.log

RAILS_ROOT="/home/ubuntu/apps/current"
RAILS_PATH="/home/ubuntu/apps/share/bundler/ruby/1.8/bin/rails"
%w{3000}.each do |port|
  God.watch do |w|
    w.name = "rails_#{port}"
    w.group = "rails"
    w.interval = 30.seconds
    w.dir = RAILS_ROOT 
    w.start = "#{RAILS_PATH} s -d -e production"
    w.start_grace = 10.seconds
    w.restart_grace = 10.seconds
    w.pid_file = File.join(RAILS_ROOT, "/tmp/pids/server.pid")

    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 10.seconds
        c.running = false
        c.notify = 'terra'
      end
    end
    
    w.restart_if do |restart|
      restart.condition(:memory_usage) do |c|
        c.above = 250.megabytes
        c.times = [3, 5] # 3 out of 5 intervals
        c.notify = 'terra'
      end
    
      restart.condition(:cpu_usage) do |c|
        c.above = 50.percent
        c.times = 2
        c.notify = 'terra'
      end
    end
    
    # lifecycle
    w.lifecycle do |on|
      on.condition(:flapping) do |c|
        c.to_state = [:start, :restart]
        c.times = 5
        c.within = 5.minute
        c.transition = :unmonitored
        c.retry_in = 10.minutes
        c.retry_times = 5
        c.retry_within = 2.hours
      end
    end
  end
end

God::Contacts::Email.defaults do |d|
  d.from_email = 'god@firenxis.com'
  d.from_name = 'God'
  d.delivery_method = :smtp
  d.server_host = "smtp.gmail.com"
  d.server_port = 587
  d.server_auth = :plain
  d.server_domain = "firenxis.com"
  d.server_user   ="god@firenxis.com"
  d.server_password = "god123god" 
  d.enable_starttls = true
end
God.contact(:email) do |c|
  c.name = 'capacitacion_terra'
  c.group = 'terra'
  c.to_email = 'capacitacion_terra@mailinator.com'
end