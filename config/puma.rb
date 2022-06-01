workers_count = ENV.fetch('WEB_CONCURRENCY', 2)
threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
base_dir = File.expand_path('..', __dir__)

workers workers_count
threads 1, threads_count

rails_env = ENV.fetch('RAILS_ENV', 'development')

environment rails_env

unless ENV.fetch('RAILS_LOG_TO_STDOUT', false)
  stdout_redirect "#{base_dir}/log/#{rails_env}.log", "#{base_dir}/log/#{rails_env}_error.log", true
end

bind        'tcp://127.0.0.1'
port        ENV.fetch('PORT', 3000)
pidfile     "#{base_dir}/tmp/pids/server.pid"

preload_app!
