require_relative "board"

class Game
  def self.configure
    levels = { "beginner" => [9, 10], "intermediate" => [16, 40], "expert" => [22, 60] }

    player_name = Game.set_option("What's your name?", /^[a-zA-Z]{1,8}$/)
    difficulty = Game.set_option("Choose a difficulty |beginner|, |intermediate|, or |expert|", /beginner|intermediate|expert/)
    size = levels[difficulty][0]
    bombs = levels[difficulty][1]
    safe_squares = (size * size) - bombs

    created_board = Game.create_a_board(size, bombs)

    Game.new(player_name, created_board, size, difficulty, safe_squares)
  end

  def self.set_option(message, pattern, value = nil)
    return value if value && value.match(pattern)

    puts "\n" + message

    value = gets.chomp
    Game.set_option(message, pattern, value)
  end

  def self.create_a_board(size, bombs)
    rows = ("_"*size*size).scan(/.{#{size}}/)
    Board.create(rows, bombs)
  end

  def initialize(player_name, board, size, difficulty, safe_squares)
    @board = board
    @size = size
    @difficulty = difficulty
    @start_time = Time.now.to_i
    @turn = 0
    @player = player_name.capitalize
    @safe_squares = safe_squares
    @flags_placed = 0
    @lose = false

    run
  end
  
  def run
    until game_over?
      current_time = Time.now.to_i
      board.render(current_time - start_time, @player)
      selected_pos = board[get_pos]
      if @flag 
        @flags_placed += 1
        board.toggle_flag(selected_pos)
      else
        @turn += 1
        board.reveal(selected_pos, @turn)
        @lose = true if selected_pos.get_val == "X"
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

  def game_over?
    win = board.safe_squares_remaining?(@safe_squares) == 0

    win || @lose
  end

  def end_game
    final_time = Time.now.to_i - start_time
    board.render(final_time, @player, true)
    puts "\n"
    if @lose 
      puts "Sorry, you lose!"
      puts "You Lost in #{@turn.to_s} turns."
    else
      puts "Congratulations! You win!" 
      puts "You won in #{@turn.to_s} turns."
    end
    @flags_placed == 1 ? n = "#{@flags_placed.to_s} tile" : n = "#{@flags_placed.to_s} tiles"
    puts "You marked #{n} with a flag."

    add_to_leaderboard(final_time) unless @lose
    retrieve_leaderboard
  end

  def retrieve_leaderboard
    puts "\n" + "Top Times - #{@difficulty.capitalize}"
    puts "\n"
    File.open("./leaderboards/#{@difficulty}.txt", "r").each { |line| puts "#{$.}.  " + line.chomp }
  end

  def add_to_leaderboard(time)
    file = "./leaderboards/#{@difficulty}.txt"
    leaderboard = []

    File.readlines(file).each { |top_score| leaderboard << top_score.chomp }

    worst_time = leaderboard[-1].split(" ")[1]

    if worst_time.to_i > time || leaderboard.length < 10
      current_time = @player.to_s + " " + time.to_s
      leaderboard << current_time

      leaderboard.sort! do |x, y|
        first_time = x.split(" ")[1].to_i
        second_time = y.split(" ")[1].to_i
        first_time <=> second_time
      end

      leaderboard.pop if leaderboard.length > 10

      puts "\n" + "You made it on the leaderboard!"
    else
      puts "\n" + "You didn't make it on the leaderboard."
      puts "Try again!"
    end

    File.open(file, "w") { |file| file.puts leaderboard }
  end

  private
  attr_reader :board, :start_time
end

Game.configure