class Tile
  def initialize(initial_value, grid)
    @grid = grid
    @value = set_value(initial_value)
    @revealed = true
  end

  def get_val
    @revealed ? @value : "*"
  end

  def set_value(value)
    value
  end
end