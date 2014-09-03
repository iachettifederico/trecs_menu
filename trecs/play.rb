require "trecs/player"
require "trecs/sources/tgz_source"

class Play
  def self.menu(*args)
    return "@prompt/Type file name" if args.empty?
    trecs_backend = args.join("/")

    line_number = ::Xiki::Line.number
    indent = ::Xiki::Line.indent

    source = TRecs::TgzSource.new(trecs_backend: trecs_backend)
    reader = source.build_reader(trecs_backend: trecs_backend)

    player_options = {
      reader:     reader,
      ticker:     XikiTicker.new,
      screen:     XikiScreen.new(line_number, indent),
      step:       100,
    }

    player = TRecs::Player.new(player_options)
    player.play

    nil
  end
end

# Support Classes
# Please do extract!

class XikiScreen
  attr_reader :line_number
  attr_reader :indent

  def initialize(line_number, indent)
    @line_number = line_number
    @indent = indent
  end
  def clear
    ::Xiki::Move.to_line(line_number)
    ::Xiki::Move.to_end
    ::Xiki::Launcher.hide
  end

  def puts(str)
    ::Xiki::View.<< "\n"
    str.each_line do |line|
      ::Xiki::View.insert("#{indent}  | #{line}")
    end
    ::Xiki::View.<< "#{indent}  "
  end
end

class XikiTicker
  attr_accessor :player
  def initialize(*)
  end

  def start
    prev_time = 0
    player.timestamps.each do |time|
      ::Xiki::View.pause((time - prev_time)/1000.0)
      player.tick(time)
      prev_time = time
    end
    true
  end
  def to_s
    "<#{self.class}>"
  end
  alias :inspect :to_s
end
