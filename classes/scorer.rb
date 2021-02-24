class Scorer
  attr_reader :totals, :roller

  def initialize(total_frames, total_pins, roll_symbols)
    @totals = Array.new(total_frames).fill(0)
    @strike = roll_symbols["strike"]
    @spare = roll_symbols["spare"]
    @total_pins = total_pins
    @inputs = []
  end

  def update(frame, roll_of_frame, inputs)
    self.inputs = inputs
    update_strike(frame, roll_of_frame) if update_strike?(roll_of_frame)
    update_spare(frame) if update_spare?(roll_of_frame)
    update_frame(frame, roll_of_frame) if update_frame?(roll_of_frame)
    update_total
  end

  private

  attr_writer :totals, :roller
  attr_accessor :inputs, :strike, :spare, :frame, :total_pins

  def update_strike(frame, roll_of_frame)
    bonus = calculate_strike_bonus

    if update_two_frames_ago?(frame, roll_of_frame)
      update_previous_frame(bonus, frame, 3)
    else
      update_previous_frame(bonus, frame)
    end
    totals[-1] += bonus
  end

  def update_strike?(roll_of_frame)
    last_roll_strike?(3) && roll_of_frame != 3
  end

  def calculate_strike_bonus
    first_bonus = last_roll_strike?(2) ? total_pins : inputs[-2].to_i
    second_bonus = last_roll_strike? ? total_pins : inputs[-1].to_i
    last_roll_spare? ? total_pins : first_bonus + second_bonus
  end

  def update_previous_frame(bonus, current_frame, frame = 2)
    totals[current_frame - frame] += bonus + total_pins
    return unless current_frame > frame
    totals[current_frame - frame] += totals[current_frame - (frame + 1)]
  end

  def update_spare(frame)
    bonus = last_roll_strike? ? total_pins : inputs[-1].to_i
    totals[frame - 2] = total_pins + bonus
    totals[frame - 2] += totals[frame - 3] if frame > 2
    totals[-1] += bonus
  end

  def update_spare?(roll_of_frame)
    last_roll_spare?(2) && roll_of_frame != 3
  end

  def update_frame(frame, roll_of_frame)
    sum = roll_of_frame == 3 || frame == 1 ? sum_frame : sum_frame(1)
    sum = 0 if final_frame?(frame) && roll_of_frame == 2
    totals[frame - 1] += sum
    return if final_frame?(frame) || frame == 1
    totals[frame - 1] += totals[frame - 2]
  end

  def update_frame?(roll_of_frame)
    !(last_roll_spare? || last_roll_strike? || last_roll_strike?(2)) &&
      roll_of_frame == 2
  end

  def update_two_frames_ago?(frame, roll_of_frame)
    (last_roll_strike?(2) || last_roll_strike?) &&
      (!final_frame?(frame) || roll_of_frame == 1)
  end

  def sum_frame(starting_position = 0)
    final_frame_score = 0
    inputs[starting_position..-1].each do |roll|
      final_frame_score += 10 if roll == strike
      final_frame_score = 10 if roll == spare && final_frame_score < 10
      final_frame_score = 20 if roll == spare && final_frame_score > 10
      final_frame_score += roll.to_i
    end
    final_frame_score
  end

  def update_total
    totals[-1] += total_pins if last_roll_strike?
    totals[-1] += total_pins - last_roll(2) if last_roll_spare?
    totals[-1] += last_roll
  end

  def no_extra_roll
    !(last_roll_strike?(2) || last_roll_spare?)
  end

  def final_frame_complete?
    (no_extra_roll && rolled_twice_this_frame?) || rolled_three_times?
  end

  def final_frame?(frame)
    frame == totals.length
  end

  def last_roll(number = 1)
    inputs[-number].to_i
  end

  def last_roll_strike?(number = 1)
    inputs[-number] == strike
  end

  def last_roll_spare?(number = 1)
    inputs[-number] == spare
  end
end
