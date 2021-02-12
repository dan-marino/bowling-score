class Bowler
  attr_accessor :inputs, :total_frames, :total_pins

  BOWL_OPTIONS = %w(miss 1 2 3 4 5 6 7 8 9)
  OPTION_SYMBOLS = { "strike" => "X", "miss" => "-", "spare" => "/" }

  def initialize(total_frames, total_pins)
    @inputs = Array.new(total_frames).map { |element| element = Array.new }
    @total_frames = total_frames
    @total_pins = total_pins
  end

  def bowl(frame)
    remaining_options = possible_options(frame)
    pins = prompt_for_input(remaining_options)
    self.inputs[frame - 1].push(OPTION_SYMBOLS[pins] || pins)
  end

  def possible_options(frame)
    last_bowl = inputs[frame - 1][-1]
    return BOWL_OPTIONS + ["strike"] if last_bowl.nil? || last_bowl == "X"

    pins_left = total_pins - last_bowl.to_i
    BOWL_OPTIONS.select { |option| option.to_i < pins_left } + ["spare"]
  end

  def prompt_for_input(options)
    pins = nil
    options_sentence = options.join(", ")
    puts "Please specify how you did on this bowl."
    puts "Choose from this list of options: #{options_sentence}."
    loop do
      pins = gets.chomp.downcase
      break if options.include?(pins)
      puts "Sorry, that's an invalid choice."
      puts "Choose from this list of options: #{options_sentence}."
    end

    pins
  end

  def option_symbols(name)
    OPTION_SYMBOLS[name]
  end
end
