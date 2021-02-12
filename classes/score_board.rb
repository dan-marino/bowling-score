class ScoreBoard
  attr_accessor :totals, :bowler, :strike, :spare, :frame, :total_pins

  def initialize(bowler, total_frames, total_pins)
    @totals = Array.new(total_frames).fill(0)
    @bowler = bowler
    @strike = bowler.option_symbols("strike")
    @spare = bowler.option_symbols("spare")
    @frame = nil
    @total_pins = total_pins
  end

  def update(frame)
    self.frame = frame
    update_strike
    update_spare
    update_frame
    update_total
  end

  def update_strike
    update_second_to_last_frame_strike if strike_on_second_to_last_frame?
    update_frame_two_strikes_in_a_row if two_previous_bowls_strikes?
    update_lastest_strike if last_frame_strike_this_frame_no_strike?
  end

  def update_spare
    if previous_frame_spare? && !bowled_three_times?
      bonus = last_bowl_strike? ? total_pins : bowler.inputs[frame - 1][0].to_i
      self.totals[frame - 2] = 10 + bonus
      self.totals[frame - 2] += totals[frame - 3] if frame > 2
      self.totals[-1] += bonus
    end
  end

  def update_frame
    unless strike_or_spare? || first_bowl_of_frame?
      prior_frame = totals[frame - 2]
      self.totals[frame - 1] += calculate_frame_sum
      unless final_frame? || frame == 1
        self.totals[frame - 1] += prior_frame
      end
    end
  end

  def update_total
    p last_bowl
    self.totals[-1] += total_pins if last_bowl_strike?
    self.totals[-1] += total_pins - second_to_last_bowl if last_bowl_spare?
    self.totals[-1] += last_bowl
  end

  def total
    totals[-1]
  end

  def two_previous_bowls_strikes?
    input = bowler.inputs
    return false if final_frame? && input[-1].length > 1
    input[frame - 3][0] == strike && previous_frame_strike? &&
    input[frame - 1].length == 1
  end

  def update_frame_two_strikes_in_a_row
    first_bonus = 10
    second_bonus = bowler.inputs[frame - 1][0]
    bonus = last_bowl_strike? ? total_pins : second_bonus.to_i
    bonus += first_bonus
    self.totals[frame - 3] += bonus + 10
    self.totals[frame - 3] += totals[frame - 4] if frame > 3
    self.totals[-1] += bonus
  end

  def last_frame_strike_this_frame_no_strike?
    return if final_frame?
    input = bowler.inputs
    previous_frame_strike? && !last_bowl_strike? &&
    input[frame - 1].length == 2
  end

  def update_lastest_strike
    bonus = last_bowl_strike? ? total_pins : calculate_frame_sum
    self.totals[frame - 2] += bonus + total_pins
    self.totals[frame - 2] += totals[frame - 3] if frame > 2
    self.totals[-1] += bonus
  end

  def update_second_to_last_frame_strike
    bonus = calculate_frame_sum
    self.totals[-1] += bonus
    self.totals[-2] = 10 + bonus + totals[-3]
  end

  def calculate_frame_sum
    final_frame_score = 0
    bowler.inputs[frame - 1].each do |bowl|
      final_frame_score += 10 if bowl == strike
      final_frame_score = 10 if bowl == spare && final_frame_score < 10
      final_frame_score = 20 if bowl == spare && final_frame_score > 10
      final_frame_score += bowl.to_i
    end
    final_frame_score
  end

  def final_frame?
    frame == totals.length
  end

  def final_tally
    final_frame_score = calculate_frame_sum
    self.totals[-1] = totals[-2] + final_frame_score
  end

  def first_bowl_of_frame?
    bowler.inputs[frame - 1].length == 1
  end

  def last_bowl
    bowler.inputs[frame - 1][-1].to_i
  end

  def second_to_last_bowl
    bowler.inputs[frame - 1][0].to_i
  end

  def last_bowl_strike?
    bowler.inputs[frame - 1][-1] == strike
  end

  def second_to_last_bowl_strike?
    bowler.inputs[frame - 1][-1] == strike
  end

  def last_bowl_spare?
    bowler.inputs[frame - 1][-1] == spare
  end

  def strike_or_spare?
    last_bowl_spare? || last_bowl_strike?
  end

  def previous_frame_spare?
    return false if final_frame? && bowler.inputs[-1].length == 1
    bowler.inputs[frame - 2].include?(spare)
  end

  def previous_frame_strike?
    bowler.inputs[frame - 2][0] == strike
  end

  def strike_on_second_to_last_frame?
    final_frame? && bowler.inputs[-1].length == 2 &&
    bowler.inputs[-2][0] == strike
  end

  def bowled_twice_this_frame?
    input = bowler.inputs
    input[frame - 1].length == 2
  end

  def bowled_three_times?
    input = bowler.inputs
    input[frame - 1].length == 3
  end

  def no_extra_bowl
    !(second_to_last_bowl_strike? || last_bowl_spare?)
  end

  def final_frame_complete?
    (no_extra_bowl && bowled_twice_this_frame?) || bowled_three_times?
  end

  def frame_complete?
    final_frame? ? final_frame_complete? : bowled_twice_this_frame? || last_bowl_strike?
  end
end
