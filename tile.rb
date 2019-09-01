class Tile
  attr_accessor :revealed

  def initialize(val)
    @value = val
    @revealed = false
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

  private
  attr_accessor :value
end