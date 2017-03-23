require 'open3'

SRC_DIR="src"
DEPLOY_PATH="/var/www/ood/apps/sys"

OOD_APPS={}
OOD_APPS["dashboard"]   = { version: "v1.10.0", repo: "https://github.com/OSC/ood-dashboard.git",    type: "rails" }
OOD_APPS["shell"]       = { version: "v1.1.2",  repo: "https://github.com/OSC/ood-shell.git",        type: "node" }
OOD_APPS["files"]       = { version: "v1.3.1",  repo: "https://github.com/OSC/ood-fileexplorer.git", type: "node" }
OOD_APPS["file-editor"] = { version: "v1.2.3",  repo: "https://github.com/OSC/ood-fileeditor.git",   type: "rails" }
OOD_APPS["activejobs"]  = { version: "v1.3.1",  repo: "https://github.com/OSC/ood-activejobs.git",   type: "rails" }
OOD_APPS["myjobs"]      = { version: "v2.1.2",  repo: "https://github.com/OSC/ood-myjobs.git",       type: "rails" }

def git_clone(repository, folder)
  system("scl enable git19 -- git clone #{repository} #{folder}")
end

def git_checkout(version, path=nil)
  system("scl enable git19 -- git checkout tags/#{version}", :chdir => path)
end

def build_node(path=nil)
  system("scl enable git19 nodejs010 -- npm install", :chdir => path)
end

def build_rails(path=nil)
  system("scl enable rh-ruby22 -- bin/bundle install --path vendor/bundle", :chdir => path)
  system("scl enable rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production", :chdir => path)
  system("scl enable rh-ruby22 nodejs010 -- bin/rake tmp:clear", :chdir => path)
end

def task_name(name)
  "install_#{name}"
end

def get_list
  app_tasks = []
  OOD_APPS.each do |name, data|
    app_tasks << task_name(name)
  end
  app_tasks
end

@app_tasks = get_list

task :default => :build_apps_parallel

task :install do
  puts "Making a directory at #{DEPLOY_PATH}"
  FileUtils.mkdir_p(DEPLOY_PATH)
  puts "Copying applications from #{File.join(Dir.pwd, SRC_DIR)} to #{DEPLOY_PATH}"
  FileUtils.cp_r(SRC_DIR, DEPLOY_PATH)
end

task :update do
  # TODO
end

task :deploy do
  # TODO
end

# Build a task to install each app
OOD_APPS.each do |name, data|
  desc %(Clone and build #{name})
  task task_name(name) do
    FileUtils.mkdir_p(SRC_DIR)
    app_path = File.join(SRC_DIR, name)
    git_clone(data[:repo], app_path)
    git_checkout(data[:version], app_path)
    eval "build_#{data[:type]}('#{app_path}')"
  end
end

multitask :build_apps_parallel => @app_tasks

task :build_apps_serial => @app_tasks
