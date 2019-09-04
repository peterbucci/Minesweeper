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
    x, y = pos
    current_tile = grid[x][y]
    out_of_bounds = (x == -1 || y == -1)
  
    return if out_of_bounds || current_tile.revealed

    add_bombs(x, y) unless @calulcated_adjacent

    current_tile.get_val == "b" ? @lose = true : @safe_squares -= 1
    current_tile.revealed = true

    return unless current_tile.get_val == "_"

    [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]]. each do |direction|
      row = direction[0]
      column = direction[1]
      reveal(direction) if grid[row] && grid[row][column]
    end
  end

  def add_bombs(row, column)
    # Get all tiles adjacent to current tile. Add to array and filter from the random_tile
    filtered = []
    (row-1..row+1).each do |i|
      next unless grid[i] 
      (column-1..column+1).each do |j|
        next if i == -1 || j == -1
        adjacent_tile = grid[i][j]
        next unless adjacent_tile
        filtered << adjacent_tile
      end
    end

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
    tile = grid[row][column]
    return unless tile.get_val == "_"

    count = 0

    (row-1..row+1).each do |i|
      next unless grid[i] 
      (column-1..column+1).each do |j|
        next if i == -1 || j == -1
        adjacent_tile = grid[i][j]
        next unless adjacent_tile
        count += 1 if adjacent_tile.get_val == "b"
      end
    end

    tile.set_val(count.to_s) if count > 0
  end

  def game_over?
    win = @safe_squares == 0

    win || lose
  end

  private
  attr_reader :grid
end