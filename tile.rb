class Tile
  attr_reader :revealed
  attr_accessor :flag

  def initialize(val, row, column)
    @value = val
    @flag = false
    @revealed = false
    @row = row
    @column = column
  end

  def render
    @revealed ? @value : @flag ? "F" : "*"
  end

  def get_val
    @value
  end

  def set_val(val)
    @value = val
  end

  def get_coordinates
    [@row, @column]
  end

  def reveal
    @revealed = true
  end
end