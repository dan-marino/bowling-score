class Bowler
  attr_accessor :inputs, :total_frames, :total_pins

  BOWL_OPTIONS = %w(miss 1 2 3 4 5 6 7 8 9)
  OPTION_SYMBOLS = { "strike" => "X", "miss" => "-", "spare" => "/" }

  def initialize(total_frames, total_pins)
    @inputs = Array.new(total_frames).map { |element| element = Array.new }
    @total_frames = total_frames
    @total_pins = total_pins
  end

  def bowl(frame, input)
    remaining_options = possible_options(frame)
    return if !remaining_options.include?(input.to_s)
    self.inputs[frame - 1].push(OPTION_SYMBOLS[input] || input)
  end

  def possible_options(frame)
    last_bowl = inputs[frame - 1][-1]
    return BOWL_OPTIONS + ["strike"] if new_set_of_pins?(frame, last_bowl)

    pins_left = total_pins - last_bowl.to_i
    BOWL_OPTIONS.select { |option| option.to_i < pins_left } + ["spare"]
  end

  def option_symbols(name)
    OPTION_SYMBOLS[name]
  end

  def new_set_of_pins?(frame, last_bowl)
    (last_bowl.nil? || last_bowl == "X") ||
    (frame == total_frames && last_bowl == "/")
  end
end
