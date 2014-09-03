require "trecs"
require "trecs/writers/json_writer"
require "trecs/recorder"
require "trecs/recording_strategies/config_strategy"
class Record
  def self.menu(*args)
    return "@prompt/Enter file name" if args.empty?
    trecs_backend = (args - [Tree.siblings.first]).select {|a|
      !a.include?(": ") && !a.include?("> ")
    }.join("/")
    return "@prompt/Enter file name after the \"record/\" command" if trecs_backend == ""
    return example(trecs_backend) if args.join("/") == trecs_backend
   
    strategy = TRecs::ConfigStrategy.new(strategies: strategies, step: 100)

    writer = TRecs::JsonWriter.new(trecs_backend: trecs_backend)

    recorder = TRecs::Recorder.new(strategy: strategy, writer: writer)
    recorder.record
    "@prompt/Recording ..."
  end

  private

  def self.strategies
    strategies ||= get_strategies
  end

  def self.get_strategies
    options_list = {}
    Tree.siblings.each do |item|
      title = item[/\A\s*>\s*(.+)/, 1]
      if title
        options_list[title] = {}
      else
        opts = options_list.keys.last
        k, v = item.gsub(/\/\Z/, "").split(/\s*:\s/, 2)
        v.to_s.gsub!(/\\n/, "\n")
        options_list[opts][k] = v
      end
    end
    strategies = options_list.map { |section, opts|
      raise "Recording strategy needed" unless opts["strategy"]
      opts = opts.each_with_object({}) { |opt, h|
        h[opt.first.to_sym] = opt.last
      }
      strategy_file = "trecs/recording_strategies/#{opts[:strategy]}_strategy"
      require strategy_file
      strategy_class_name = [
        "TRecs::",
        opts[:strategy].split(/[-_\s]/).map(&:capitalize),
        "Strategy"
      ].join
      strategy_class = strategy_class_name.split("::").reduce(Object) { |a, e| a.const_get e }
      strategy_class.new(opts)
    }
    strategies
  end

  def self.example(file_name=nil)
    example = <<EOF
> First TRecs
- strategy: incremental
- message: Welcome to
- step: 50
> Second TRecs
- strategy: fly_from_right
- message: TRecs
- step: 1
- command: echo "Welcome to" <frame>
EOF
    if file_name
      example << "@trecs/play/#{file_name}/"
    end
    
    example
  end
end
