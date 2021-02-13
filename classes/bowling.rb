require_relative "bowler"
require_relative "score_board"
require_relative "display"

class Bowling
  attr_reader :score, :current_frame, :bowler, :display

  TOTAL_FRAMES = 10
  TOTAL_PINS = 10

  def initialize
    reset
  end

  def reset
    @bowler = Bowler.new(TOTAL_FRAMES, TOTAL_PINS)
    @score = ScoreBoard.new(bowler, TOTAL_FRAMES, TOTAL_PINS)
    @display = Display.new
    @current_frame = 1
  end

  def play(input)
    unless game_over?
      bowler.bowl(current_frame, input)
      score.update(current_frame)
    end

    advance_frame if score.frame_complete?

    display.score_table(score.totals, bowler.inputs, current_frame, game_over?)
  end

  def total_score
    score.total
  end

  def total_frame_score(frame = current_frame)
    score.totals[frame - 1]
  end

  def inputs(frame)
    bowler.inputs[frame - 1]
  end

  private

  attr_writer :score, :current_frame, :bowler, :display
  
  def advance_frame
    self.current_frame += 1
  end

  def game_over?
    current_frame > TOTAL_FRAMES
  end


end
