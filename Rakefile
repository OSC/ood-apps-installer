require "ostruct"
require "pathname"

# Blessed apps
OOD_APPS = {
  dashboard: {
    name: "dashboard",
    type: "ruby",
    rails: true,
    repo: "https://github.com/OSC/ood-dashboard.git",
    tag: "v1.10.0"
  },
  shell: {
    name: "shell",
    type: "nodejs",
    repo: "https://github.com/OSC/ood-shell.git",
    tag: "v1.1.2"
  },
  files: {
    name: "files",
    type: "nodejs",
    repo: "https://github.com/OSC/ood-fileexplorer.git",
    tag: "v1.3.1"
  },
  file_editor: {
    name: "file-editor",
    type: "ruby",
    rails: true,
    repo: "https://github.com/OSC/ood-fileeditor.git",
    tag: "v1.2.3"
  },
  active_jobs: {
    name: "activejobs",
    type: "ruby",
    rails: true,
    repo: "https://github.com/OSC/ood-activejobs.git",
    tag: "v1.3.1"
  },
  my_jobs: {
    name: "myjobs",
    type: "ruby",
    rails: true,
    repo: "https://github.com/OSC/ood-myjobs.git",
    tag: "v2.1.2"
  }
}

# System apps base-URI path
# Example: access dashboard
#   https://ondemand.domain.com/pun/sys/dashboard
BASE_URI = ENV["BASE_URI"] || "/pun/sys"

# Build options
PREFIX ||= Pathname.new(ENV["PREFIX"] || "/var/www/ood/apps/sys")
OBJDIR ||= Pathname.new(ENV["OBJDIR"] || "build")

def all_apps
  OOD_APPS.each_with_object ({}) { |(k, v), h| h[k] = OpenStruct.new(v) }
end

def ruby_apps
  all_apps.select { |k, h| h.type == "ruby" }
end

def node_apps
  all_apps.select { |k, h| h.type == "nodejs" }
end

def rails_apps
  ruby_apps.select { |k, h| h.rails }
end

#
# Tasks
#

task :default => :build

# Tasks for all apps
all_apps.each do |k, h|
  build_dir  = OBJDIR.join(h.name)
  prefix_dir = PREFIX.join(h.name)

  # Create app build dir by cloning app
  directory build_dir do
    sh "git clone #{h.repo} #{build_dir}"
  end

  # Create app prefix dir
  directory prefix_dir

  # Checkout the latest code for a given app version
  task "#{k}_checkout" => build_dir do
    # determine remote origin url
    origin = `git -C #{build_dir} config --get remote.origin.url 2> /dev/null`.strip
    # set origin if changed
    if h.repo != origin
      sh "git -C #{build_dir} remote set-url origin #{h.repo}"
    end

    # determine currently checked out tag
    tag = `git -C #{build_dir} describe --tag 2> /dev/null`.strip
    # get appropriate tag if doesn't match
    if h.repo != origin || h.tag != tag
      sh "git -C #{build_dir} fetch"
      sh "git -C #{build_dir} -c advice.detachedHead=false checkout #{h.tag}"
    end
  end

  # Build the app
  namespace :build do
    desc "Build the app: '#{h.name}'"
    if h.type == "ruby" && h.rails
      build_prereq = "#{k}_assets_precompile"
    elsif h.type == "ruby"
      build_prereq = "#{k}_bundle_install"
    elsif h.type == "nodejs"
      build_prereq = "#{k}_npm_install"
    end
    task k => build_prereq do
      touch build_dir.join("tmp", "restart.txt")
    end
  end

  # Install the app
  namespace :install do
    desc "Install the app: '#{h.name}'"
    task k => prefix_dir do
      sh "rsync -rlptv --delete --quiet #{build_dir}/ #{prefix_dir}"
    end
  end

  # Clean the app
  namespace :clean do
    desc "Clean the app: '#{h.name}'"
    task k do
      rm_rf build_dir
    end
  end
end

# Tasks for Ruby apps
ruby_apps.each do |k, h|
  build_dir = OBJDIR.join(h.name)

  # Bundle install gems
  task "#{k}_bundle_install" => "#{k}_checkout" do
    # check if bundle gems already installed
    `#{build_dir}/bin/bundle check &> /dev/null`
    # install them if not
    unless $?.success?
      sh "#{build_dir}/bin/bundle install --path=vendor/bundle"
    end
    sh "#{build_dir}/bin/bundle clean" # clean up unused gems
  end
end

# Tasks for NodeJS apps
node_apps.each do |k, h|
  build_dir = OBJDIR.join(h.name)

  # NPM install packages
  task "#{k}_npm_install" => "#{k}_checkout" do
    sh "npm --prefix #{build_dir} install"
    sh "npm --prefix #{build_dir} prune &> /dev/null" # clean up unused packages
  end
end

# Tasks for Rails apps
rails_apps.each do |k, h|
  build_dir = OBJDIR.join(h.name)

  # Precompile assets
  task "#{k}_assets_precompile" => "#{k}_bundle_install" do
    sh "#{build_dir}/bin/rake -f #{build_dir}/Rakefile assets:clobber"
    sh "#{build_dir}/bin/rake -f #{build_dir}/Rakefile assets:precompile RAILS_ENV=production RAILS_ROOT=#{build_dir} RAILS_RELATIVE_URL_ROOT=#{BASE_URI}/#{h.name}"
    rm_rf build_dir.join("tmp", "cache")
  end
end

# Build all the apps
namespace :build do
  task :all => all_apps.keys
end

# Install all the apps
namespace :install do
  task :all => all_apps.keys
end

# Clean all the apps
namespace :clean do
  task :all => all_apps.keys
end

desc "Build all apps"
task :build => "build:all"

desc "Install all apps"
task :install => "install:all"

desc "Clean all apps"
task :clean => "clean:all"
