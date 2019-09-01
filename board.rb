require_relative "tile"

class Board
  def self.from_file(filename)
    rows = File.readlines(filename).map(&:chomp)
    tiles = rows.map { |row| row.split("").map { |square| Tile.new(square == "b") } }

    Board.new(tiles)
  end

  def initialize(grid)
    @grid = grid
  end
end

board = Board.from_file("./grids/minefield1.txt")