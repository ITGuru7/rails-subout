namespace :subout do

  namespace :assets do

    task :link do
      cwd = Dir.pwd
      deploy = DateTime.now.to_i.to_s

      dir = "#{cwd}/public"
      current = dir + "/assets/--DEPLOY--"
      destination = dir + "/assets/#{deploy}"
      `mkdir -p #{destination}`

      targets = ['/css','/images','/img','/js','/partials','/font']
      targets.each do |target|
        start_path = dir + target
        final_path = destination + target
        puts "linking #{start_path} to #{final_path}"
        `ln -nfs #{start_path} #{final_path}`
      end

      index_file = dir + '/index.html'

      `ln -nfs #{destination} #{current}`
      `cp #{index_file} #{dir}/index_backup.html`

      token = '--DEPLOY--'
      replacement_files = [index_file]
      replacement_files.each do |file|
        text = File.read(file)
        text = text.gsub(/--DEPLOY--/, deploy)
        File.open(file, 'w') { |file| file.write(text) }
      end

      `echo "#{deploy}" > ./deploy.txt`
    end

  end

end
