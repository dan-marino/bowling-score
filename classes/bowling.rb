require_relative "bowler"
require_relative "scorer"
require_relative "display"

class Bowling
  attr_reader :scorer, :bowler, :display, :inputs, :total_score,
              :frame, :roll_of_frame

  ROLLS_PER_FRAME = 2
  TOTAL_FRAMES = 10
  TOTAL_PINS = 10
  ROLL_SYMBOLS = { "strike" => "X", "spare" => "/", "miss" => "-" }

  def initialize
    reset
  end

  def reset
    @frame_scores = []
    @inputs = []
    @total_score = 0
    @frame = 1
    @roll_of_frame = 0
    @bowler = Bowler.new(TOTAL_FRAMES, TOTAL_PINS, ROLL_SYMBOLS)
    @scorer = Scorer.new(TOTAL_FRAMES, TOTAL_PINS, ROLL_SYMBOLS)
    @display = Display.new
  end

  def play(input)
    unless game_over?
      pins = bowler.roll(input, frame)
      unless pins.nil?
        advance_roll_of_frame
        scorer.update(frame, roll_of_frame, last_three_rolls)
      end

    end

    advance_frame if frame_complete?

    display.score_table(scorer.totals, bowler.inputs, frame, game_over?)
  end

  def next_set_of_pins
    game_over? ? [] : bowler.possible_options(frame)
  end

  def total_score
    scorer.totals[-1]
  end

  def total_frame_score(frame = nil)
    frame.nil? ? scorer.totals : scorer.totals[frame - 1]
  end

  def inputs(frame = nil)
    frame.nil? ? bowler.inputs : bowler.inputs[frame - 1]
  end

  def rolls_left
    extra_roll? ? calculate_rolls_left + 1 : calculate_rolls_left
  end

  def frame_scores
    scorer.totals
  end

  private

  attr_writer :scorer, :bowler, :display, :inputs, :total_score,
              :frame, :roll_of_frame

  def advance_frame
    self.roll_of_frame = 0
    self.frame += 1
  end

  def advance_roll_of_frame
    self.roll_of_frame += 1
  end

  def game_over?
    frame > TOTAL_FRAMES
  end

  def final_frame?
    frame == TOTAL_FRAMES
  end

  def calculate_rolls_left
    ROLLS_PER_FRAME - roll_of_frame
  end

  def extra_roll?
    return false unless final_frame?

    last_two_rolls = last_three_rolls[1..]

    extra_roll1 = last_two_rolls[-1] == ROLL_SYMBOLS["strike"] &&
    roll_of_frame == 1

    extra_roll2 = (last_two_rolls.include?(ROLL_SYMBOLS["strike"]) ||
    last_two_rolls.include?(ROLL_SYMBOLS["spare"])) && roll_of_frame == 2

    extra_roll1 || extra_roll2
  end

  def final_frame_done?(rolls)
    ((roll_of_frame == 2) &&
    !(rolls.include?(ROLL_SYMBOLS["strike"]) ||
    rolls.include?(ROLL_SYMBOLS["spare"]))) || roll_of_frame == 3 
  end

  def non_final_frame_done?(rolls)
    roll_of_frame == 2 || rolls[-1] == ROLL_SYMBOLS["strike"]
  end

  def last_three_rolls
    inputs = bowler.inputs.flatten
    inputs.length > 3 ? bowler.inputs.flatten[-3...] : inputs
  end

  def frame_complete?
    rolls = last_three_rolls
    return if rolls.nil?
    final_frame? ? final_frame_done?(rolls) : non_final_frame_done?(rolls)
  end
end
