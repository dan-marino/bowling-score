require 'terminal-table'

class Display
  attr_reader :display

  def initialize
  end

  def score_table(score, inputs, frame, game_over)
    clear_screen
    print_score_header(frame, game_over)
    print_score_table(score, inputs)
  end

  private

  attr_writer :display

  def print_score_header(frame, game_over)
    midgame_message = "You are currently on frame #{frame}\n\n"
    endgame_message = "Thanks for playing! Run `game.reset` to play again\n\n"
    puts game_over ? endgame_message : midgame_message
  end

  def print_score_table(score, inputs)
    score_table = create_score_table(score, inputs)
    puts score_table
  end

  def create_score_table(score, inputs)
    rows = []
    frame_array = ["Frame"]
    input_array = ["Input"]
    score_array = ["Score"]

    score.each.with_index do |frame_score, frame|
      frame_score = " " if frame_score.zero?
      frame_array << frame + 1
      input_array << inputs[frame].join(" ")
      score_array << frame_score
    end
    rows << frame_array << input_array << score_array
    Terminal::Table.new :rows => rows, :style => { width: 80 }
  end

  def clear_screen
    system 'clear'
  end
end
