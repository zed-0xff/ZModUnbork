task :default => :update

task :update do
  require 'yaml'
  info = YAML.load_file('info.yml')
  in_lines = File.readlines('steam.txt')

  out_lines = []
  i = 0
  while i < in_lines.size
    line = in_lines[i]
    out_lines << line

    if line =~ /^\[h1\]Revived mods/
      out_lines << "[list]\n"
      info['mods'].sort_by(&:last).each do |id, name|
        out_lines << "   [*][url=https://steamcommunity.com/sharedfiles/filedetails/?id=#{id}]#{name}[/url]\n"
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
