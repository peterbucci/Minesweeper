require_relative "tile"

class Board
  def self.from_file(filename)
    rows = File.readlines(filename).map(&:chomp)
    tiles = rows.map { |row| row.split("").map { |tile| Tile.new(tile) } }

    Board.new(tiles)
  end

  def initialize(grid)
    @grid = grid

    grid.each_with_index do |row, i|
      row.each_with_index { |_, j| calculate_adjacent_bombs(i, j) }
    end 
  end

  def render
    puts "\e[H\e[2J"
    puts "    " + @grid.map.with_index { |_, i| i.to_s }.join(" ")
    puts ""

    grid.each_with_index do |row, i|
      display_row = i.to_s + " | "
      row.each { |tile| display_row += tile.render + " " }
      puts display_row
    end

    puts ""
  end

  def reveal(pos)
    x, y = pos

    return if x == -1 || y == -1
    return if grid[x][y].revealed
    grid[x][y].revealed = true
    return unless grid[x][y].get_val == "_"


    reveal([x - 1, y]) if grid[x - 1]
    reveal([x + 1, y]) if grid[x + 1]
    reveal([x, y - 1]) if grid[x][y - 1]
    reveal([x, y + 1]) if grid[x][y + 1]
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
    win = grid.flatten.all? { |tile| tile.revealed || tile.get_val == "b" }
    lose = grid.flatten.any? { |tile| tile.revealed && tile.get_val == "b" }
    win || lose
  end

  private
  attr_reader :grid
end