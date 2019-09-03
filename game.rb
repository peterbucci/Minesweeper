require_relative "board"

class Game
  def self.configure
    @map_type = Game.set_option("Choose a map type |PREBUILT| or |RANDOM|", /random|prebuilt/)

    if @map_type == "random"
      difficulty = Game.set_option("Choose a difficulty |EASY|, |MEDIUM|, or |HARD|", /easy|medium|hard/)

      created_board = Game.create_a_board(difficulty)
    else
      created_board = Game.choose_a_board
    end

    Game.new(created_board)
  end

  def self.set_option(message, pattern, value = nil)
    return value if value && value.match(pattern)

    puts "\n" + message

    value = gets.chomp.downcase
    Game.set_option(message, pattern, value)
  end

  def self.create_a_board(difficulty)
    size, bombs = 9, 10 if difficulty == "easy"
    size, bombs = 16, 40 if difficulty == "medium"
    size, bombs = 22, 60 if difficulty == "hard"

    empty_tiles = Array.new((size * size) - bombs, "_")
    bomb_tiles = Array.new(bombs, "b")
    tiles = (empty_tiles + bomb_tiles).shuffle
    
    rows = tiles.join("").scan(/.{#{size}}/)
    Board.from_file(rows)
  end

  def self.choose_a_board
    prebuilt_maps = Dir.children("./grids")
    user_input = nil

    until prebuilt_maps.include?(user_input)
      puts "\n" + "Choose a map"
      puts "\n" + prebuilt_maps.join(" | ").upcase

      user_input = gets.chomp.downcase
      user_input += ".txt" unless user_input.include?(".txt")
    end

    rows = File.readlines("./grids/#{user_input}").map(&:chomp)
    Board.from_file(rows)
  end

  def initialize(board)
    @board = board

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

Game.configure