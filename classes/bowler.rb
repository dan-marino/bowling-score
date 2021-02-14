class Bowler
  attr_reader :inputs, :roll_symbols, :roll_options

  def initialize(total_frames, total_pins, roll_symbols)
    @inputs = Array.new(total_frames).map { |_| [] }
    @total_pins = total_pins
    @roll_symbols = roll_symbols
    @roll_options = ["miss"] + (1...total_pins).to_a.map(&:to_s)
  end

  def roll(input, frame)
    remaining_options = possible_options(frame)
    return if !remaining_options.include?(input.to_s)
    self.inputs[frame - 1].push(roll_symbols[input] || input)
    roll_symbols[input] || input
  end

  def possible_options(frame)
    last_roll = inputs[frame - 1][-1]
    return roll_options + ["strike"] if new_set_of_pins?(last_roll)
    pins_left = total_pins - last_roll.to_i
    roll_options.select { |option| option.to_i < pins_left } + ["spare"]
  end

  private

  attr_accessor :total_pins
  attr_writer :inputs, :roll_symbols, :roll_options

  def new_set_of_pins?(last_roll)
    (last_roll.nil? || last_roll == roll_symbols["strike"]) ||
    (last_roll == roll_symbols["spare"])
  end
end
