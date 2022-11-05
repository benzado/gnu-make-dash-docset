require 'pathname'

puts %Q[
  CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);
  CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);
]

INSERT_SQL = %Q[
  INSERT INTO searchIndex(name, type, path) VALUES ('%s','%s','%s');
]

PATTERN = %r[<title>(.+)</title>]

def quote(s)
  s.gsub(/&amp;/, '&').gsub(/'/, "\\'")
end

ARGV.each do |arg|
  Pathname.glob(arg) do |path|
    match = path.each_line.lazy.map { |line| PATTERN.match(line) }.find { |m| m }
    if match
      title = match[1]
      title.delete_prefix!('GNU make: ') # older docs
      title.delete_suffix!(' (GNU make)') # newer docs
      printf INSERT_SQL, quote(title), 'Guide', path.basename
    else
      $stderr.puts "#{path}: no title found"
    end
  end
end
