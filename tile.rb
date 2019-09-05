class Tile
  attr_accessor :revealed

  def initialize(val, row, column)
    @value = val
    @revealed = false
    @row = row
    @column = column
  end

  def render
    @revealed ? value : "*"
  end

  def get_val
    value
  end

  def set_val(val)
    self.value = val
  end

  def get_coordinates
    [@row, @column]
  end

  private
  attr_accessor :value
end