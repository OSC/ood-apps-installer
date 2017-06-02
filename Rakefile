require "pathname"

# Blessed apps
OOD_APPS = [
  {
    name: "dashboard",
    repo: "https://github.com/OSC/ood-dashboard.git",
    tag: "v1.11.1"
  },
  {
    name: "shell",
    repo: "https://github.com/OSC/ood-shell.git",
    tag: "v1.2.2"
  },
  {
    name: "files",
    repo: "https://github.com/OSC/ood-fileexplorer.git",
    tag: "v1.3.3"
  },
  {
    name: "file-editor",
    repo: "https://github.com/OSC/ood-fileeditor.git",
    tag: "v1.3.0"
  },
  {
    name: "activejobs",
    repo: "https://github.com/OSC/ood-activejobs.git",
    tag: "v1.4.3"
  },
  {
    name: "myjobs",
    repo: "https://github.com/OSC/ood-myjobs.git",
    tag: "v2.4.0"
  }
]

# System apps base-URI path
# Example: access dashboard
#   https://ondemand.domain.com/pun/sys/dashboard
BASE_URI = ENV["BASE_URI"] || "/pun/sys"

# Build options
PREFIX ||= Pathname.new(ENV["PREFIX"] || "/var/www/ood/apps/sys")
OBJDIR ||= Pathname.new(ENV["OBJDIR"] || "build")

# Class that describes a list of app objects
class Apps
  include Enumerable

  def initialize(apps = [])
    @apps = apps.map { |app| App.new(app.to_h) }
  end

  def [](name)
    @apps.detect { |app| app == name }
  end

  def each(&block)
    @apps.each(&block)
  end
end

# Class that describes an app
class App
  attr_reader :name, :repo, :tag

  def initialize(opts = {})
    # symbolize keys
    opts = opts.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }

    @name = opts.fetch(:name) { raise ArgumentError, "No name specified. Missing argument: name" }.to_s
    @repo = opts.fetch(:repo) { raise ArgumentError, "No repo specified. Missing argument: repo" }.to_s
    @tag  = opts.fetch(:tag)  { raise ArgumentError, "No tag specified. Missing argument: tag" }.to_s
  end

  def build_root
    OBJDIR.join(name)
  end

  def install_root
    PREFIX.join(name)
  end

  def ==(other)
    name == other.to_sym
  end

  def to_sym
    name
  end

  def to_h
    {
      name: name,
      repo: repo,
      tag: tag
    }
  end
end

def all_apps
  Apps.new OOD_APPS
end

#
# Tasks
#

task :default => :build

# Tasks for all apps
all_apps.each do |app|
  # Create app install directory
  directory app.install_root

  # Create app build directory by cloning app
  directory app.build_root do
    sh "git clone #{app.repo} #{app.build_root}"
  end

  # Checkout the app
  namespace :checkout do
    task app.name => app.build_root do
      # determine remote origin url
      origin = `git -C #{app.build_root} config --get remote.origin.url 2> /dev/null`.strip
      # set origin if changed
      if app.repo != origin
        sh "git -C #{app.build_root} remote set-url origin #{app.repo}"
      end

      # determine currently checked out tag
      tag = `git -C #{app.build_root} describe --tag 2> /dev/null`.strip
      # get appropriate tag if doesn't match
      if app.repo != origin || app.tag != tag
        sh "git -C #{app.build_root} fetch"
        sh "git -C #{app.build_root} -c advice.detachedHead=false checkout #{app.tag}"
      end
    end
  end

  # Build the app
  namespace :build do
    task :all => all_apps.map(&:name)

    desc "Build the app: '#{app.name}'"
    task app.name => "checkout:#{app.name}" do
      setup_path = app.build_root.join("bin", "setup")
      if setup_path.exist? && setup_path.executable?
        sh "PASSENGER_APP_ENV=production PASSENGER_BASE_URI=#{BASE_URI}/#{app.name} #{setup_path}"
      end
    end
  end

  # Install the app
  namespace :install do
    task :all => all_apps.map(&:name)

    desc "Install the app: '#{app.name}'"
    task app.name => app.install_root do
      sh "rsync -rlptv --delete --quiet #{app.build_root}/ #{app.install_root}"
    end
  end

  # Clean the app
  namespace :clean do
    task :all => all_apps.map(&:name)

    desc "Clean the app: '#{app.name}'"
    task app.name do
      rm_rf app.build_root
    end
  end
end

desc "Build all apps"
task :build => "build:all"

desc "Install all apps"
task :install => "install:all"

desc "Clean all apps"
task :clean => "clean:all"
