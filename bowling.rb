require 'terminal-table'

require_relative "bowler"
require_relative "score_board"

class Bowling
  attr_accessor :score, :current_frame, :bowler

  TOTAL_FRAMES = 10
  TOTAL_PINS = 10

  def initialize
    @bowler = Bowler.new(TOTAL_FRAMES, TOTAL_PINS)
    @score = ScoreBoard.new(bowler, TOTAL_FRAMES, TOTAL_PINS)
    @current_frame = 1
  end

  def play
    display_score
    bowl_frame
    if final_frame?
      display_score
      bowl_final_frame
    end

    advance_frame
    display_score
  end

  def display_score_header
    midgame_message = "You are currently on frame #{current_frame}\n\n"
    endgame_message = "Thanks for playing! Here's the final score:\n\n"
    puts current_frame > TOTAL_FRAMES ? endgame_message : midgame_message
  end

  def display_score_table
    score_table = create_score_table
    puts score_table
  end

  def create_score_table
    rows = []
    frame_array = ["Frame"]
    input_array = ["Input"]
    score_array = ["Score"]

    score.totals.each.with_index do |frame_score, frame|
      frame_score = " " if frame_score.zero?
      frame_array << frame + 1
      input_array << bowler.inputs[frame].join(" ")
      score_array << frame_score
    end
    rows << frame_array << input_array << score_array
    Terminal::Table.new :rows => rows, :style => { width: 80 }
  end

  def display_score
    clear_screen
    display_score_header
    display_score_table
  end

  def clear_screen
    system 'clear'
  end

  def bowl_frame
    bowler.bowl(current_frame)
    score.update(current_frame)

    unless score.last_bowl_strike?
      display_score
      bowler.bowl(current_frame)
      score.update(current_frame)
    end
  end

  def extra_bowl_from_strike
    bowl_frame
    display_score
  end

  def bowl_final_frame
    extra_bowl_from_strike if score.last_bowl_strike?
    bowl_frame if score.strike_or_spare?
    score.final_tally
  end

  def advance_frame
    self.current_frame += 1
  end

  def final_frame?
    current_frame == TOTAL_FRAMES
  end
end
