require_relative "tile"

class Board
  attr_reader :lose


  def self.create(rows, bombs)
    count = rows.join("").length
    tiles = rows.each_with_index.map { |row, i| row.split("").each_with_index.map { |tile, j| Tile.new(tile, i, j) } }

    Board.new(tiles, count, bombs)
  end

  def initialize(grid, safe_squares, bombs)
    @grid = grid
    @first_turn = true
    @bombs_to_add = bombs

    @safe_squares_remaining = safe_squares
    @lose = false
  end

  def render(game_over = false)
    puts "\e[H\e[2J"
    puts "     " + @grid.map.with_index { |_, i| i < 10 ? i.to_s + " " : i.to_s }.join(" ") + "\n\n"

    grid.each_with_index do |row, i|
      i = " " + i.to_s if i < 10
      display_row = i.to_s + " | "
      row.each { |tile| game_over ? display_row += tile.get_val + "  " : display_row += tile.render + "  " }
      puts display_row
    end
  end

  def reveal(current_tile)
    add_bombs(current_tile) && calculate_adjacent_bombs if @first_turn

    row, column = current_tile.get_coordinates
    out_of_bounds = (row == -1 || column == -1)
    return if out_of_bounds || current_tile.revealed
  
    current_tile.reveal && check_for_bomb(current_tile)

    get_adjacent_tiles(current_tile).each { |tile| reveal(tile) } if current_tile.get_val == "_"
  end

  def toggle_flag(tile)
    tile.flag ? tile.flag = false : tile.flag = true
  end

  def check_for_bomb(current_tile)
    if current_tile.get_val == "b"
      @lose = true
      current_tile.set_val("X")
    else
      @safe_squares_remaining -= 1
    end
  end

  def game_over?
    win = @safe_squares_remaining == 0

    win || lose
  end

  def add_bombs(current_tile)
    return true if @bombs_to_add == 0
    tile_and_adjacent = get_adjacent_tiles(current_tile)
    random_tile = grid.sample.reject {|tile| tile.get_val == "b" || tile_and_adjacent.include?(tile) }.sample
    random_tile.set_val("b")

    @bombs_to_add -= 1
    @safe_squares_remaining -= 1
  
    add_bombs(current_tile)
  end

  def calculate_adjacent_bombs
    grid.each do |row| 
      row.each do |current_tile|
        next unless current_tile.get_val == "_"

        bomb_count = 0
        adjacent_tiles = get_adjacent_tiles(current_tile)
        adjacent_tiles.each { |tile| bomb_count += 1 if tile.get_val == "b" }
        current_tile.set_val(bomb_count.to_s) if bomb_count > 0
      end
    end

    @first_turn = false
  end

  def get_adjacent_tiles(current_tile)
    row, column = current_tile.get_coordinates
    adjacent_rows = (row-1..row+1)
    adjacent_columns = (column-1..column+1)

    adjacent_tiles = []

    adjacent_rows.each do |i|
      next unless grid[i]
  
      adjacent_columns.each do |j|
        adjacent_tile = grid[i][j]
        in_bounds = i >= 0 && j >= 0
        next unless in_bounds && adjacent_tile
  
        adjacent_tiles << adjacent_tile
      end
    end

    adjacent_tiles
  end

  def [](pos)
    row, column = pos
    grid[row][column]
  end

  private
  attr_reader :grid
end