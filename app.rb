require "./classes/bowling"

game = Bowling.new

# Walkthrough of a sample game
#
# game.play(3)         # Frame 1
# game.play("miss")    # Frame 1
# game.play(9)         # Frame 2
# game.play("spare")   # Frame 2
# game.play("strike")  # Frame 3
# game.play("strike")  # Frame 4
# game.play(2)         # Frame 5
# game.play(3)         # Frame 5
# game.play(3)         # Frame 6
# game.play(6)         # Frame 6
# game.play(4)         # Frame 7
# game.play("spare")   # Frame 7
# game.play("strike")  # Frame 8
# game.play(9)         # Frame 9
# game.play("spare")   # Frame 9
# game.play("strike")  # Frame 10
# game.play("strike")  # Frame 10
# game.play("strike")  # Frame 10
#
# final output should be this:
#
# +-------+-------+------+------+------+------+------+------+------+-----+-------+
# | Frame | 1     | 2    | 3    | 4    | 5    | 6    | 7    | 8    | 9   | 10    |
# | Input | 3 -   | 9 /  | X    | X    | 2 3  | 3 6  | 4 /  | X    | 9 / | X X X |
# | Score | 3     | 23   | 45   | 60   | 65   | 74   | 94   | 114  | 134 | 164   |
# +-------+-------+------+------+------+------+------+------+------+-----+-------+
