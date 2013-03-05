require './config/environment.rb'

class Deploy < Thor
  desc "local_to_remote", "Deploy <local branch> to <remote server>"
  def local_to_remote(local_branch, remote_server)
    return unless system("git checkout #{local_branch}")
    return unless system("git pull origin #{local_branch}")
    git_status = `git status`
    puts git_status
    return unless git_status == "# On branch #{local_branch}\nnothing to commit (working directory clean)\n"

    return unless system("git checkout #{remote_server}")
    return unless system("git reset #{local_branch} --hard")
    return unless system("git push origin #{remote_server} -f")
    return unless system("kumade #{remote_server}")
    return unless system("git checkout master")
  end
end
