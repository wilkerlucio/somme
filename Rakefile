require 'bundler'

Bundler.setup

class ChromeExtensionBuilder
  class ScriptJoiner
    def initialize(scripts)
      @scripts = scripts
    end

    def build
      Uglifier.compile(joined_files)
    end

    private

    def joined_files
      @scripts.inject("") do |output, path|
        output += "\n" + open(path).read
      end
    end
  end

  def initialize(path, target)
    @path = path
    @target = target
  end

  def build
    build_scripts
  end

  private

  def build_scripts
    script_number = 0

    if scripts = manifest["content_scripts"]
      scripts.each do |content_script|
        if js = content_script["js"]
          path = "lib/cs#{script_number}.js"
          result = ScriptJoiner.new(js).build

          script_number += 1
        end
      end
    end
  end

  def manifest
    @manifest ||= JSON.parse(open(manifest_path).read)
  end

  def manifest_path
    File.join(@path, "manifest.json")
  end
end

def simple_save(path, content)
  File.open(path, "w") do |f|
    f << content
  end
end

desc "Build a release zip for the extension"
task :release do
  require 'json'
  require 'uglifier'
  require 'fileutils'

  target = File.join("tmp", "build")

  # make sure target dir exists and it's clear
  puts "Cleaning up build directory"
  FileUtils.mkdir_p(target)
  rm_rf(target)
  FileUtils.mkdir_p(target)

  # load manifest
  manifest = JSON.parse(open("manifest.json").read)

  # lib
  puts "Saving uglified javascript"
  js = manifest["content_scripts"][0]["js"]
  manifest["content_scripts"][0]["js"] = ["lib/somme.js"]

  js_content = js.inject("") do |output, path|
    output += "\n" + open(path).read
  end

  uglified = Uglifier.compile(js_content)

  FileUtils.mkdir_p(File.join(target, "lib"))

  simple_save(File.join(target, "lib", "somme.js"), uglified)
  simple_save(File.join(target, "manifest.json"), JSON.dump(manifest))

  FileUtils.cp_r("images", target)

  puts "Zipping build for release"
  Dir.chdir target do
    system "zip -r '../../dist/somme-#{manifest["version"]}.zip' ."
  end

  puts "Done"
end
