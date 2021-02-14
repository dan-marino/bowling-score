require_relative "bowler"
require_relative "scorer"
require_relative "display"

class Bowling
  attr_reader :scorer, :bowler, :display, :frame_scores, :inputs, :total_score,
              :frame, :roll_of_frame

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
    bowler.possible_options(frame)
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

  private

  attr_writer :scorer, :bowler, :display, :frame_scores, :inputs, :total_score,
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

  def final_frame_done?(rolls)
    (roll_of_frame == 3) &&
    !(rolls.include?(ROLL_SYMBOLS["stirke"]) ||
    rolls.include?(ROLL_SYMBOLS["spare"]))
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

  def update_state
    self.state["frame_scores"] = scorer.totals
    self.state["inputs"] = bowler.inputs
    self.state["total_score"] = scorer.totals[-1]
  end
end
