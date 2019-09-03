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

  def get_pos(message = "Enter a position to reveal it on the board. (e.g. 1,2)", pos = nil)
    return pos if pos && valid_pos?(pos)

    puts "\n" + message
    puts "> "

    pos = parse_pos(gets.chomp)
    get_pos("Invalid position entered (did you use a comma?)", pos)
  end

  def valid_pos?(pos)
    pos.is_a?(Array) && pos.length == 2 && pos.all? { |x| x.between?(0, 8) }
  end

  def parse_pos(pos)
    pos.split(",").map(&:to_i)
  end

  def end_game
    board.render

    puts "\n"
    if board.lose
      puts "Sorry! You Lose!"
    else
      puts "Congratulations! You win!"
    end
  end

  private
  attr_reader :board
end

Game.new