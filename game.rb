require_relative "board"

class Game
  def initialize
    @board = Board.from_file("./grids/minefield1.txt")

    run
  end
  
  def run
    until board.game_over?
      board.render
      board.reveal(get_pos)
    end

    end_game
  end

  def get_pos
    pos = nil

    until pos && valid_pos?(pos)
      puts "Enter a position to reveal it on the board. (e.g. 1,2)"
      pos = gets.chomp
    end

    pos.split(",").map(&:to_i)
  end

  def valid_pos?(pos)
    true
  end

  def end_game
    board.render
    puts "Game Over"
  end

  private
  attr_reader :board
end

Game.new