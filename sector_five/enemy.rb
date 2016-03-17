class Enemy
  attr_reader :x, :y, :radius
  SPEED = 4

  def initialize(window)
    @window = window
    @radius = 20
    @x = rand(@radius .. (@window.width - @radius))
    @y = 0
    @image = Gosu::Image.new('images/enemy.png')
  end

  def move
    @y += SPEED
  end

  def draw
    @image.draw(@x - @radius, @y - @radius, 1)
  end
end