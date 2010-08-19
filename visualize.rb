# encoding: utf-8
# Shoes app to visualize better COBOTS fights
# eregon, whyday 19/08/2010
=begin
+  +  +  +  +  +  +  +  +  +
        $     $     $

+  +  +  +  +  +  +  +  +  +
     $     $     $     $

+  +  +  +  +  +  +  +  +  +
 >> >> >> ## ## ## << << <<
 >> >> >> ## ## ## << << <<
+  +  +--+  +  +  +--+  +  +
 ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^
 ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^
+  +--+  +  +  +  +  +--+  +
 ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^
 ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^
+--+  +  +  +  +  +  +  +--+
 ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^
 ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^
+  +  +  +  +  +  +  +  +  +
  c           @           r

+  +  +  +  +  +  +  +  +  +
=end
DIR = "logs"

def load_file file
  contents = File.open(file, 'rb', &:read)

  maps = contents.scan(/^! BEGIN_MAP !\n(.+?)\n! END_MAP !$|^[+-]+?\n(.+?)\n[+-]+?$/m).map(&:compact)
  maps.map! { |map| Map.new(map.first) }

  # R first, C second
  moves = contents.scan(/^!(\w):  (\w+), (\w):  (\w+)!$|^! MOVES (\w):(\w+) (\w):(\w+) !$/).map { |move|
    move.compact!
    if move.first =~ /r/i
      [move[1], move[3]]
    else
      [move[3], move[1]]
    end
  }

  [maps, moves]
end

class Map
  attr_reader :lines
  def initialize str
    @lines = str.lines.map(&:chomp)
  end

  include Enumerable
  def each(&b)
    @lines.each(&b)
  end

  def width
    @lines.first.size
  end

  def height
    @lines.size
  end
end

Shoes.app width: 800, height: 700 do
  COLORS = {
    ?+ => red, ?- => red, ?| => red,
    ?$ => green,
    ?# => orange,
    ?> => blue, ?< => blue, ?^ => blue,
    ?@ => purple,
    ?r => purple, ?c => purple, ?R => purple, ?C => purple
  }
  def draw_main map, moves
    moves ||= []
    @main = flow do
      para "R:#{moves.first} C:#{moves.last}\n"
      map.each { |line|
        line.each_char { |char|
          color = COLORS[char] || black
          para char, font: "Monaco", size: "x-small", stroke: color
        }
        para "\n"
      }
    end
  end

  list_box items: Dir["#{DIR}/*"] { |file|
    @main.clear if @main
    @maps, @moves = load_file(file.text)
    draw_main @maps.first, @moves[@i = 0]
  }

  button("pred") {
    if @maps[@i-1]
      @main.clear
      @i -= 1
      draw_main @maps[@i], @moves[@i]
    end
  }
  button("next") {
    if @maps[@i+1]
      @main.clear
      @i += 1
      draw_main @maps[@i], @moves[@i]
    end
  }
end
