task :default => [:info, :build]

MOD_ID   = "ZModUnbork"
MOD_TYPE = "shared"
VERSIONS = {
  "42" => "17",
}

VERSIONS.each do |ver, jdk_ver|
  desc "build for #{ver}"
  task "build:#{ver}" do
    Dir.chdir("java") do
      env = {
        "JAVA_HOME" => "/Library/Java/JavaVirtualMachines/openjdk-#{jdk_ver}.jdk/Contents/Home"
      }
      sh env, "gradle build -PZVersion=#{ver}"
    end
    dst_dir = "#{ver}/media/java/#{MOD_TYPE}"
    FileUtils.mkdir_p dst_dir
    jar_dst = "#{dst_dir}/#{MOD_ID}.jar"
    libs_jar = "java/build/libs/#{MOD_ID}-#{ver}.jar"
    libs_zbs = "#{libs_jar}.zbs"
    FileUtils.mv libs_jar, jar_dst
    if File.exist?(libs_zbs)
      FileUtils.mv libs_zbs, "#{jar_dst}.zbs"
    end
  end
end

desc "build all"
task :build => VERSIONS.keys.map { |ver| "build:#{ver}" }

desc "update steam.txt from info.yml"
task :info do
  require 'yaml'
  info = YAML.load_file('info.yml')
  in_lines = File.readlines('steam.txt')

  class ModInfo
    attr_accessor :id, :title, :zb, :comment

    def initialize(id, title:, comment: nil, zb: false, exhume: false)
      @id      = id
      @comment = comment
      @title   = title
      @comment ||= " (with [url=https://steamcommunity.com/sharedfiles/filedetails/?id=3619862853]ZombieBuddy[/url] for java-side patches)" if zb
      @comment ||= " (with [url=https://steamcommunity.com/sharedfiles/filedetails/?id=3718604798]Exhume 41[/url] for loading B41 mod on B42)" if exhume
    end
  end

  mods = [
    info['mods'].map     { |id, title| ModInfo.new(id, title:) },
    info['zb_mods'].map  { |id, title| ModInfo.new(id, title:, zb: true) },
    info['b41_mods'].map { |id, title| ModInfo.new(id, title:, exhume: true) },
  ].map(&:to_a).flatten.sort_by(&:title)

  out_lines = []
  i = 0
  while i < in_lines.size
    line = in_lines[i]
    out_lines << line

    if line =~ /^\[h1\]Revived mods/
      out_lines << "[list]\n"
      mods.each do |m|
        out_lines << "   [*][url=https://steamcommunity.com/sharedfiles/filedetails/?id=#{m.id}]#{m.title}[/url]#{m.comment}\n"
      end
      info['mod_pairs'].each do |pair|
        out_lines << "   [*]" + pair.map{ |id, name| "[url=https://steamcommunity.com/sharedfiles/filedetails/?id=#{id}]#{name}[/url]" }.join(" + ") + "\n"
      end
      out_lines << "[/list]\n"
      out_lines << "\n"
        
      i += 1 while in_lines[i].strip != ""
    end

    i += 1
  end

  File.write('steam.txt', out_lines.join)
end

desc "show steam url"
task :url do
  puts "https://steamcommunity.com/sharedfiles/filedetails/?id=3677147974"
end
