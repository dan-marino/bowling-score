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
    first_bonus = last_roll_strike?(2) ? total_pins : inputs[-2].to_i
    second_bonus = last_roll_strike? ? total_pins : inputs[-1].to_i
    bonus = last_roll_spare? ? total_pins : first_bonus + second_bonus

    if update_two_frames_ago?(frame, roll_of_frame)
      self.totals[frame - 3] += bonus + total_pins
      self.totals[frame - 3] += totals[frame - 4] if frame > 3
    else
      self.totals[frame - 2] += bonus + total_pins
      self.totals[frame - 2] += totals[frame - 3] if frame > 2
    end
    self.totals[-1] += bonus
  end

  def update_strike?(roll_of_frame)
    last_roll_strike?(3) && roll_of_frame != 3
  end

  def update_spare(frame)
    bonus = last_roll_strike? ? total_pins : inputs[-1].to_i
    self.totals[frame - 2] = 10 + bonus
    self.totals[frame - 2] += totals[frame - 3] if frame > 2
    self.totals[-1] += bonus
  end

  def update_spare?(roll_of_frame)
    last_roll_spare?(2) && roll_of_frame != 3
  end

  def update_frame(frame, roll_of_frame)
    prior_frame = totals[frame - 2]

    sum = roll_of_frame == 3 || frame == 1 ? sum_frame : sum_frame(1)
    sum = 0 if final_frame?(frame) && roll_of_frame == 2
    self.totals[frame - 1] += sum
    unless final_frame?(frame) || frame == 1
      self.totals[frame - 1] += prior_frame
    end
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
    inputs[starting_position...].each do |roll|
      final_frame_score += 10 if roll == strike
      final_frame_score = 10 if roll == spare && final_frame_score < 10
      final_frame_score = 20 if roll == spare && final_frame_score > 10
      final_frame_score += roll.to_i
    end
    final_frame_score
  end

  def update_total
    self.totals[-1] += total_pins if last_roll_strike?
    self.totals[-1] += total_pins - last_roll(2) if last_roll_spare?
    self.totals[-1] += last_roll
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
