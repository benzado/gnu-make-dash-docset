require 'pathname'

puts %Q[
  CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);
  CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);
]

INSERT_SQL = %Q[
  INSERT INTO searchIndex(name, type, path) VALUES ('%s','%s','%s');
]

PATTERN = %r[<title>GNU make: (.+)</title>]

def quote(s)
  s.gsub(/&amp;/, '&').gsub(/'/, "\\'")
end

ARGV.each do |arg|
  Pathname.glob(arg) do |path|
    match = path.each_line.lazy.map { |line| PATTERN.match(line) }.find { |m| m }
    if match
      printf INSERT_SQL, quote(match[1]), 'Guide', path.basename
    else
      $stderr.puts "%{path.basename}: no title found"
    end
  end
end
