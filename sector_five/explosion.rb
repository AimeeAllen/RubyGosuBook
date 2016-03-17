class Explosion
  RADIUS = 30

  attr_reader :finished

  def initialize(window, x, y)
    @x = x
    @y = y
    @radius = RADIUS
    @window = window
    @finished = false
    @image_index = 0
    @images = Gosu::Image.load_tiles('images/explosions.png', 60, 60) #chops up the sprite sheet into 60x60 images
  end

  def draw
    if @finished == false && @image_index < @images.size
      @images[@image_index].draw(@x - @radius, @y - @radius, 2)
      @image_index += 1
    else
      @finished = true
    end
  end
end
