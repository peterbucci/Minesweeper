require_relative "tile"

class Board
  def self.from_file(filename)
    rows = File.readlines(filename).map(&:chomp)
    tiles = rows.map { |row| row.split("").map { |tile| Tile.new(tile, rows) } }

    Board.new(tiles)
  end

  def initialize(grid)
    @grid = grid

    render
  end

  def render
    puts "\e[H\e[2J"
    puts "    " + @grid.map.with_index { |_, i| i.to_s }.join(" ")
    grid.each_with_index do |row, i|
      display_row = i.to_s + " | "
      row.each { |tile| display_row += tile.get_val + " " }
      puts display_row
    end
    puts ""
  end

  private
  attr_reader :grid
end

board = Board.from_file("./grids/minefield1.txt")