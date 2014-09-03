require "trecs/version"

class Trecs
  def self.version
    [TRecs::VERSION]
  end

  def self.install
    out = `rvm all do gem uninstall trecs -a -x && rvm all do gem install trecs `
    out.each_line.map {|l| "| #{l}"}.join
  end
end
