require_relative "tile"

class Board
  def self.from_file(filename)
    rows = File.readlines(filename).map(&:chomp)
    tiles = rows.map { |row| row.split("").map { |tile| Tile.new(tile) } }

    Board.new(tiles)
  end

  def initialize(grid)
    @grid = grid

    render
  end

  def render
    puts "\e[H\e[2J"
    puts "    " + @grid.map.with_index { |_, i| i.to_s }.join(" ")
    puts ""

    grid.each_with_index do |row, i|
      display_row = i.to_s + " | "
      row.each_with_index { |_, j| display_row += calculate_adjacent_bombs(i, j) + " " }
      puts display_row
    end

    puts ""
  end

  def reveal(pos = [0, 1])
    x, y = pos
    grid[x][y].revealed = true
    render
  end

  def calculate_adjacent_bombs(row, column)
    tile = grid[row][column]
    return tile.render unless tile.render == "_"

    count = 0

    (row-1..row+1).each do |i|
      next unless grid[i] 
      (column-1..column+1).each do |j|
        adjacent_tile = grid[i][j]
        next unless adjacent_tile
        count += 1 if adjacent_tile.get_val == "b"
      end
    end

    count == 0 ? tile.render : count.to_s
  end

  private
  attr_reader :grid
end

board = Board.from_file("./grids/minefield1.txt")
board.reveal
board.reveal([5, 5])
board.reveal([3, 7])