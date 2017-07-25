require "json"
require "pathname"

# List of all apps to deploy and install
# @return [Array<App>] list of all apps
def all_apps
  json = ENV["OOD_APPS"] || File.read(ENV["OOD_CONFIG"] || File.expand_path("../config.json", __FILE__))
  JSON.parse(json).map { |app| App.new(app.to_h) }
end

# Class that describes an OOD app to be built and installed
class App
  class << self
    # System apps base-URI path
    # @example Access dashboard
    #   https://ondemand.domain.com/pun/sys/dashboard
    # @return [String] base-uri path
    def base_uri
      ENV["BASE_URI"] || "/pun/sys"
    end

    # The root directory where all the built apps will be installed under
    # @return [Pathname] the install root directory
    def install_root
      Pathname.new(ENV["PREFIX"] || "/var/www/ood/apps/sys")
    end

    # The root directory where all the apps will be built under
    # @return [Pathname] the build root directory
    def build_root
      Pathname.new(ENV["OBJDIR"] || "build")
    end
  end

  # The name of this app
  # @return [String] app name
  attr_reader :name

  # The git repo of this app
  # @return [String] app's git repo
  attr_reader :repo

  # The git tag to checkout for this app
  # @return [String] app's git tag
  attr_reader :tag

  # @param opts [Hash{#to_sym => Object}] options decsribing app
  # @option opts [String] :name The name of the app
  # @option opts [String] :repo The git repo
  # @option opts [String] :tag The tag of the git repo to checkout
  def initialize(opts = {})
    # symbolize keys and drop any set to `nil`
    opts = opts.each_with_object({}) { |(k, v), h| h[k.to_sym] = v unless v.nil?}

    @name = opts.fetch(:name) { raise ArgumentError, "No name specified. Missing argument: name" }.to_s
    @repo = opts.fetch(:repo) { raise ArgumentError, "No repo specified. Missing argument: repo" }.to_s
    @tag  = opts.fetch(:tag)  { raise ArgumentError, "No tag specified. Missing argument: tag" }.to_s
    @optional = opts.fetch(:optional, false)
    raise ArgumentError, "Argument must be a boolean: optional" unless [true, false].include?(@optional)
  end

  # Whether app should be optionally built and/or installed
  # @return [Boolean] whether app is optional
  def optional?
    @optional
  end

  # The root directory where this app will be built
  # @return [Pathname] build directory
  def build_root
    self.class.build_root.join(name)
  end

  # The root directory where this app will be installed
  # @return [Pathname] install directory
  def install_root
    self.class.install_root.join(name)
  end

  # The base-URI for this app
  # @return [String] base-uri
  def base_uri
    "#{self.class.base_uri}/#{name}"
  end
end

#
# Tasks
#

task :default => :build

# Directory tasks
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
end

# Building tasks
namespace :build do
  task :all => all_apps.reject(&:optional?).map(&:name)

  all_apps.each do |app|
    desc "Build the app: '#{app.name}'"
    task app.name => "checkout:#{app.name}" do
      setup_path = app.build_root.join("bin", "setup")
      if setup_path.exist? && setup_path.executable?
        sh "PASSENGER_APP_ENV=production PASSENGER_BASE_URI=#{app.base_uri} #{setup_path}"
      end
    end
  end
end

# Installing tasks
namespace :install do
  task :all => all_apps.reject(&:optional?).map(&:name)

  all_apps.each do |app|
    desc "Install the app: '#{app.name}'"
    task app.name => app.install_root do
      sh "rsync -rlptv --delete --quiet #{app.build_root}/ #{app.install_root}"
    end
  end
end

# Cleaning tasks
namespace :clean do
  task :all => all_apps.reject(&:optional?).map(&:name)

  all_apps.each do |app|
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
