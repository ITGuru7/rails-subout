namespace :subout do

  namespace :assets do

    task :link do
      cwd = Dir.pwd
      deploy = DateTime.now.to_i.to_s

      dir = "#{cwd}/public"
      current = dir + "/assets/current"
      destination = dir + "/assets/#{deploy}"
      `mkdir -p #{destination}`

      targets = ['/css','/images','/img','/js','/partials','/font']
      targets.each do |target|
        start_path = dir + target
        final_path = destination + target
        puts "linking #{start_path} to #{final_path}"
        `ln -nfs #{start_path} #{final_path}`
      end

      `ln -nfs #{destination} #{current}`
      `mv #{dir}/index.html #{current}/index.html`
    end

    task :substitution do
      # replace index.html {DEPLOY}
    end

  end

end
