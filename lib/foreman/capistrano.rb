if defined?(Capistrano)
  Capistrano::Configuration.instance(:must_exist).load do

    namespace :foreman do
      desc <<-DESC
        Export the Procfile to upstart.  Will use sudo if available.

        You can override any of these defaults by setting the variables shown below.

        set :foreman_format,      "upstart"
        set :foreman_location,    "/etc/init"
        set :foreman_procfile,    "Procfile"
        set :foreman_app,         application
        set :foreman_user,        user
        set :foreman_log,         'shared_path/log'
        set :foreman_concurrency, false
      DESC
      task :export, :roles => :app do
        bundle_cmd          = fetch(:bundle_cmd, "bundle")
        foreman_format      = fetch(:foreman_format, "upstart")
        foreman_location    = fetch(:foreman_location, "/etc/init")
        foreman_procfile    = fetch(:foreman_procfile, "Procfile")
        foreman_app         = fetch(:foreman_app, application)
        foreman_user        = fetch(:foreman_user, user)
        foreman_log         = fetch(:foreman_log, "#{shared_path}/log")
        foreman_concurrency = fetch(:foreman_concurrency, false)

        args = ["#{foreman_format} #{foreman_location}"]
        args << "-f #{foreman_procfile}"
        args << "-a #{foreman_app}"
        args << "-u #{foreman_user}"
        args << "-l #{foreman_log}"
        args << "-c #{foreman_concurrency}" if foreman_concurrency
        run "cd #{release_path} && #{sudo} #{bundle_cmd} exec foreman export #{args.join(' ')}"
      end

      desc "Start the application services"
      task :start, :roles => :app do
        run "#{sudo} start #{application}"
      end

      desc "Stop the application services"
      task :stop, :roles => :app do
        run "#{sudo} stop #{application}"
      end

      desc "Restart the application services"
      task :restart, :roles => :app do
        run "#{sudo} start #{application} || #{sudo} restart #{application}"
      end

    end
  end
end
