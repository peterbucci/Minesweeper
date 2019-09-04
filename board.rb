require_relative "tile"

class Board
  attr_reader :size, :lose


  def self.create(rows, bombs)
    count = rows.join("").length
    tiles = rows.map { |row| row.split("").map { |tile| Tile.new(tile) } }

    Board.new(tiles, count, bombs)
  end

  def initialize(grid, safe_squares, bombs)
    @grid = grid
    @size = grid.length

    @bombs_to_add = bombs
    @calulcated_adjacent = nil

    @safe_squares = safe_squares
    @lose = false
  end

  def render
    puts "\e[H\e[2J"
    puts "     " + @grid.map.with_index { |_, i| i < 10 ? i.to_s + " " : i.to_s }.join(" ") + "\n\n"

    grid.each_with_index do |row, i|
      i = " " + i.to_s if i < 10
      display_row = i.to_s + " | "
      row.each { |tile| display_row += tile.render + "  " }
      puts display_row
    end
  end

  def reveal(pos)
    row, column = pos
    current_tile = grid[row][column]
    out_of_bounds = (row == -1 || column == -1)
  
    return if out_of_bounds || current_tile.revealed
  
    add_bombs(row, column) unless @calulcated_adjacent
  
    current_tile.get_val == "b" ? @lose = true : @safe_squares -= 1
    current_tile.revealed = true
  
    return unless current_tile.get_val == "_"
  
    # Try to condense all the directional looping into a single method?
    adjacent_rows = (row-1..row+1)
    adjacent_columns = (column-1..column+1)
  
    adjacent_rows.each do |i|
      next unless grid[i]
  
      adjacent_columns.each do |j|
        adjacent_tile = grid[i][j]
        in_bounds = i >= 0 && j >= 0
        next unless in_bounds && adjacent_tile
  
        reveal([i, j]) unless adjacent_tile.revealed
      end
    end
  end

  def add_bombs(row, column)
    # 2nd loop already condensed
    filtered = search_adjacent_tiles(row, column, adjacent_tiles = [])

    if @bombs_to_add > 0
      random_tile = grid.sample.reject {|tile| tile.get_val == "b" || filtered.include?(tile) }.sample
      random_tile.set_val("b")

      @bombs_to_add -= 1
      @safe_squares -= 1
    
      add_bombs(row, column)
    else
      @calulcated_adjacent = true

      grid.each_with_index do |row, i|
        row.each_with_index { |_, j| calculate_adjacent_bombs(i, j) }
      end 
    end
  end

  def calculate_adjacent_bombs(row, column)
    current_tile = grid[row][column]
    return unless current_tile.get_val == "_"
    
    # 3rd loop already condensed
    bomb_count = search_adjacent_tiles(row, column, adjacent_bombs = 0)
    current_tile.set_val(bomb_count.to_s) if bomb_count > 0
  end

  def game_over?
    win = @safe_squares == 0

    win || lose
  end

  def search_adjacent_tiles(row, column, return_value = nil)
    adjacent_rows = (row-1..row+1)
    adjacent_columns = (column-1..column+1)
  
    adjacent_rows.each do |i|
      next unless grid[i]
  
      adjacent_columns.each do |j|
        adjacent_tile = grid[i][j]
        in_bounds = i >= 0 && j >= 0
        next unless in_bounds && adjacent_tile
  
        (adjacent_tile.get_val == "b" && return_value += 1) if return_value.is_a?(Integer) # For counting adjacent bombs during map creation
        return_value << adjacent_tile if return_value.is_a?(Array) # For placing bombs after your first selection
      end
    end

    return_value
  end

  private
  attr_reader :grid
end