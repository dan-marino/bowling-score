require 'terminal-table'

class Bowling
  attr_accessor :score, :current_frame, :bowler

  TOTAL_FRAMES = 10
  TOTAL_PINS = 10
  BOWL1_OPTIONS = %w(strike miss 1 2 3 4 5 6 7 8 9)
  BOWL2_OPTIONS = %w(spare miss 1 2 3 4 5 6 7 8 9)
  OPTION_SYMBOLS = { "strike" => "X", "miss" => "-", "spare" => "/" }
  STRIKE_VALUE = { "X" => 10 } # TODO maybe change this

  def initialize()
    @current_frame = 1
    @score = Array.new(10).fill(0)
    @bowler = Bowler.new()
  end

  def play
    display_welcome_message
    until final_frame?
      display_score
      bowler_bowls
      update_score
      clear_screen
      advance_frame
    end
    display_score
    bowl_final_frame
    advance_frame
    clear_screen
    display_score
  end

  def display_score
    rows = []
    frame_array = ["Frame"]
    input_array = ["Input"]
    score_array = ["Score"]

    score.each.with_index do |frame_score, frame|
      frame_score = " " if frame_score.zero?
      frame_array << frame + 1
      input_array << bowler.inputs[frame].join(" ")
      score_array << frame_score
    end
    rows << frame_array << input_array << score_array
    score_table = Terminal::Table.new :rows => rows, :style => { width: 80 }
    puts "You are currently on frame #{current_frame}."
    puts score_table
  end

  def print_score_table(frame_strip, input_strip, score_strip)
    message = "You are bowling in frame #{current_frame}\n\n"
    closing_message = "Hope you had fun. Here's the fine score\n\n"
    puts current_frame > 10 ? closing_message : message
    puts frame_strip
    puts input_strip
    puts score_strip
    puts "\n"
  end

  def bowler_bowls
    bowl1_input = initial_bowl
    return if bowl1_input == "X"

    display_score
    pins_left = TOTAL_PINS - bowl1_input.to_i
    options_left = BOWL2_OPTIONS.select { |option| option.to_i < pins_left }
    bowler.bowl(options_left, current_frame, OPTION_SYMBOLS)
  end

  def update_score()
    update_strike
    update_spare
    update_frame
    update_total
  end

  def advance_frame
    self.current_frame += 1
  end

  def final_frame?
    current_frame == TOTAL_FRAMES
  end

  def update_strike
    update_9th_frame_strike if strike_on_9th_frame?
    update_two_strikes_in_a_row if two_previous_bowls_strikes?
    update_last_strike if last_frame_strike_this_frame_no_strike?
  end

  def update_spare
    if previous_frame_spare?
      second_bonus = bowler.inputs[current_frame - 1][0]
      bonus = STRIKE_VALUE[second_bonus] || second_bonus.to_i
      score[current_frame - 2] = 10 + bonus
      score[current_frame - 2] += score[current_frame - 3] if current_frame > 2
      score[-1] += bonus unless final_frame?
    end
  end

  def update_frame
    unless strike_or_spare
      prior_frame = score[current_frame - 2]
      self.score[current_frame - 1] += sum_of_frame
      self.score[current_frame - 1] += prior_frame unless final_frame?
    end
  end

  def update_total
    return if final_frame?
    self.score[-1] += strike_or_spare ? 10 : calculate_frame_sum
  end

  def strike_or_spare
    bowler.inputs[current_frame - 1][-1].match(/(X|\/)/)
  end

  def previous_frame_spare?
    input = bowler.inputs
    return false if final_frame? && input[-1].length == 1
    input[current_frame - 2].include?("/")
  end

  def sum_of_frame
    bowler.inputs[current_frame - 1].map(&:to_i).sum
  end

  def two_previous_bowls_strikes?
    input = bowler.inputs
    return false if final_frame? && input[-1].length > 1
    input[current_frame - 3][0] == "X" && input[current_frame - 2][0] == "X"
  end

  def update_two_strikes_in_a_row
    first_bonus = 10
    second_bonus = bowler.inputs[current_frame - 1][0]
    bonus = STRIKE_VALUE[second_bonus] || second_bonus.to_i
    bonus += first_bonus
    score[current_frame - 3] += bonus + 10
    score[current_frame - 3] += score[current_frame - 4] if current_frame > 3
    score[-1] += bonus
  end

  def last_frame_strike_this_frame_no_strike?
    input = bowler.inputs
    input[current_frame - 2][0] == "X" && input[current_frame - 1][-1] != "X"
  end

  def update_last_strike
    bonus = strike_or_spare ? 10 : calculate_frame_sum
    score[current_frame - 2] += bonus + 10
    score[current_frame - 2] += score[current_frame - 3] if current_frame > 2
    score[-1] += bonus
  end

  def strike_on_9th_frame?
    final_frame? && bowler.inputs[-1].length == 2
  end

  def update_9th_frame_strike
    bonus = calculate_frame_sum
    score[-1] += bonus
    score[-2] = 10 + bonus + score[-3]
  end

  def calculate_frame_sum
    final_frame_score = 0
    bowler.inputs[current_frame - 1].each do |bowl|
      final_frame_score += 10 if bowl == "X"
      final_frame_score = 10 if bowl == "/" && final_frame_score < 10
      final_frame_score = 20 if bowl == "/" && final_frame_score > 10
      final_frame_score += bowl.to_i
    end
    return final_frame_score
  end

  def extra_bowl_from_strike
    bowler_bowls
    update_strike
    clear_screen
    display_score
  end

  def initial_bowl
    bowler.bowl(BOWL1_OPTIONS, current_frame, OPTION_SYMBOLS)
  end

  def bowl_final_frame
    bowler_bowls
    update_score
    clear_screen
    display_score

    extra_bowl_from_strike if bowler.inputs[-1][0] == "X"
    initial_bowl if strike_or_spare

    final_frame_score = calculate_frame_sum

    score[-1] += final_frame_score
  end

  def clear_screen
    system 'clear'
  end

  def display_welcome_message
    clear_screen
    puts "Welcome to Bowling!"
    puts ""
  end

end

class Bowler
  attr_accessor :inputs
  def initialize
    @inputs = Array.new(10).map { |element| element = Array.new }
  end

  def bowl(options, frame, symbols)
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

    self.inputs[frame - 1].push(symbols[pins] || pins)
    symbols[pins] || pins
  end
end

game = Bowling.new
game.play
