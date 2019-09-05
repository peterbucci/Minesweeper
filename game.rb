require_relative "board"

class Game
  def self.configure
    levels = { "easy" => [9, 10], "medium" => [16, 40], "hard" => [22, 60] }

    player_name = Game.set_option("What's your name?", /^[a-zA-Z]{1,5}$/)
    difficulty = Game.set_option("Choose a difficulty |EASY|, |MEDIUM|, or |HARD|", /easy|medium|hard/)
    size = levels[difficulty][0]
    bombs = levels[difficulty][1]

    created_board = Game.create_a_board(size, bombs)

    Game.new(player_name, created_board, size)
  end

  def self.set_option(message, pattern, value = nil)
    return value if value && value.match(pattern)

    puts "\n" + message

    value = gets.chomp.downcase
    Game.set_option(message, pattern, value)
  end

  def self.create_a_board(size, bombs)
    rows = ("_"*size*size).scan(/.{#{size}}/)
    Board.create(rows, bombs)
  end

  def initialize(player_name, board, size)
    @board = board
    @size = size
    @start_time = Time.now.to_i
    @player = player_name.capitalize

    run
  end
  
  def run
    until board.game_over?
      current_time = Time.now.to_i
      board.render(current_time - start_time, @player)
      selected_pos = board[get_pos]
      if @flag 
        board.toggle_flag(selected_pos)
      else
        board.take_turn
        board.reveal(selected_pos)
      end
    end

    end_game
  end

  def get_pos(message = "Enter a position to reveal it on the board. (e.g. 1,2)", pos = nil)
    return pos if pos && valid_pos?(pos)

    puts "\n" + message
    puts "> "

    user_input = gets.chomp
    if user_input[0] == "f"
      @flag = true
      user_input.slice!(0)
    else
      @flag = false
    end
    pos = parse_pos(user_input)
    get_pos("Invalid position entered (did you use a comma?)", pos)
  end

  def valid_pos?(pos)
    pos.is_a?(Array) && pos.length == 2 && pos.all? { |x| x.between?(0, @size) }
  end

  def parse_pos(pos)
    pos.split(",").map(&:to_i)
  end

  def end_game
    current_time = Time.now.to_i
    board.render(current_time - start_time, @player, true)
    puts "\n"
    board.game_over_message
  end

  private
  attr_reader :board, :start_time
end

Game.configure