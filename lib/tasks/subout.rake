namespace :subout do

  namespace :assets do

    task :link do
      cwd = Dir.pwd
      dir = "#{cwd}/public"
      files_dir = dir + '/files'
      deploy = Time.now.to_i.to_s

      dirs = []
      Dir.entries(files_dir).each do |entry|
        if File.directory?(File.join(files_dir,entry)) and entry =~ /^\/?\d+$/
          ts = entry.to_i
          dirs << ts
        end
      end

      limit = 5
      if dirs.length >= limit
        dirs.sort!
        dir_path = File.join(files_dir,dirs.first.to_s)
        puts "Clean up: Deleting asset directoy \"#{dir_path}\""
        `rm -fr #{dir_path}`
      end

      destination = dir + "/files/#{deploy}"
      `mkdir -p #{destination}`

      targets = ['/css','/images','/img','/js','/partials','/fonts', '/mo']
      targets.each do |target|
        start_path = dir + target
        final_path = destination + target
        puts "linking #{start_path} to #{final_path}"
        `cp -R #{start_path} #{final_path}`
      end

      index_file = dir + '/index_development.html'
      index_replacement_file = dir + '/index_production.html'

      index_mo_file = dir + '/mo/index_development.html'
      index_mo_replacement_file = dir + '/mo/index_production.html'

      token = '--DEPLOY--'
      replacement_files = {
        index_file => index_replacement_file,
        index_mo_file => index_mo_replacement_file

      }
      replacement_files.each do |origin, dest|
        text = File.read(origin)
        text = text.gsub(/--DEPLOY--/, deploy)
        File.open(dest, 'w') { |file| file.write(text) }
      end

      `echo "#{deploy}" > ./deploy.txt`
    end

  end

  namespace :data do
    # event data update
    task :fix_event_data_for_consumer_form do
      Event.all.each do |event|
        event.eventable_type = "Opportunity"
        event.save
      end
    end
  end

end
