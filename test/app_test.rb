require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

require_relative '../app.rb'

class BowlingTest < MiniTest::Test

  def setup
    @game = Bowling.new
  end

  def test_bowling_game_starts_on_frame_1
    assert_equal(1, @game.current_frame)
  end

  def test_bowling_game_starts_with_score_of_0
    assert_equal(0, @game.total_score)
  end

  def test_bowling_non_strike_on_first_bowl_does_not_advance_frame
    @game.play(5)
    assert_equal(1, @game.current_frame)
  end

  def test_total_score_updates_after_non_strike_bowl
    @game.play(5)
    assert_equal(5, @game.total_score)
  end

  def test_bowling_strike_on_first_bowl_advances_frame
    @game.play("strike")
    assert_equal(2, @game.current_frame)
  end

  def test_completing_frame_advances_frame
    @game.play(4)
    @game.play(4)
    assert_equal(2, @game.current_frame)
  end

  def test_total_score_updates_after_strike_bowl
    @game.play("strike")
    assert_equal(10, @game.total_score)
  end

  def test_frame_total_does_not_update_until_frame_completed
    @game.play(5)
    assert_equal(0, @game.total_frame_score(1))
  end

  def test_frame_total_updates_after_frame_completed
    @game.play(5)
    @game.play(4)
    assert_equal(9, @game.total_frame_score(1))
  end

  def test_cannot_bowl_spare_on_first_bowl_of_frame
    @game.play("spare")
    assert_equal([], @game.inputs(1))
  end

  def test_cannot_bowl_strike_on_second_bowl_of_frame
    @game.play(5)
    @game.play("strike")
    assert_equal([5], @game.inputs(1))
  end

  def test_can_bowl_spare_on_second_bowl_of_frame
    @game.play(5)
    @game.play("spare")
    assert_equal([5, "/"], @game.inputs(1))
  end

  def test_can_bowl_spare_on_second_bowl_of_frame
    @game.play(5)
    @game.play("spare")
    assert_equal([5, "/"], @game.inputs(1))
  end

  def test_bowling_strike_does_not_update_frame_total_immediately
    @game.play("strike")
    assert_equal(0, @game.total_frame_score(1))
  end

  def test_bowling_strike_does_not_update_frame_total_after_next_bowl
    @game.play("strike")
    @game.play(9)
    assert_equal(0, @game.total_frame_score(1))
  end

  def test_bowling_strike_updates_frame_total_after_next_two_bowls
    @game.play("strike")
    @game.play(4)
    @game.play("miss")
    assert_equal(14, @game.total_frame_score(1))
  end

  def test_bowling_spare_does_not_update_frame_total_immediately
    @game.play(8)
    @game.play("spare")
    assert_equal(0, @game.total_frame_score(1))
  end

  def test_bowling_strike_updates_frame_total_after_next_bowl
    @game.play(8)
    @game.play("spare")
    @game.play("strike")
    assert_equal(20, @game.total_frame_score(1))
  end

  def test_cannot_enter_invalid_number
    @game.play(80)
    @game.play(-1)
    @game.play(1.9)
    assert_equal([], @game.inputs(1))
  end

  def test_cannot_enter_invalid_number_on_second_bowl
    @game.play(5)
    @game.play(6) # Over the total pin limit
    assert_equal([5], @game.inputs(1))
  end

  def test_perfect_game_score
    12.times { @game.play("strike") }
    assert_equal(300, @game.total_score)
  end

  def test_perfect_game_score
    12.times { @game.play("strike") }
    assert_equal(300, @game.total_score)
  end

  def test_not_getting_extra_bowl_in_10th_frame
    20.times { @game.play(4) }
    assert_equal([4, 4], @game.inputs(10))
  end

  def test_correct_frame_score_for_complete_random_game1
    @game.play(4)         # Frame 1
    @game.play(5)         # Frame 1
    @game.play(2)         # Frame 2
    @game.play("spare")   # Frame 2
    @game.play("strike")  # Frame 3
    @game.play("strike")  # Frame 4
    @game.play(7)         # Frame 5
    @game.play(2)         # Frame 5
    @game.play(5)         # Frame 6
    @game.play(4)         # Frame 6
    @game.play(8)         # Frame 7
    @game.play("spare")   # Frame 7
    @game.play("strike")  # Frame 8
    @game.play(4)         # Frame 9
    @game.play("spare")   # Frame 9
    @game.play(3)         # Frame 10
    @game.play("spare")   # Frame 10
    @game.play("strike")  # Frame 10

    frame_scores = []
    1.upto(10) { |frame| frame_scores << @game.total_frame_score(frame) }

    expected_output = [9, 29, 56, 75, 84, 93, 113, 133, 146, 166]

    assert_equal(frame_scores, expected_output)
  end

  def test_game_reset_resets_score_to_0
    20.times { @game.play(4) }
    @game.reset
    assert_equal(0, @game.total_score)
  end

  def test_game_reset_resets_frame_to_1
    20.times { @game.play(4) }
    @game.reset
    assert_equal(1, @game.current_frame)
  end
end
