class Player < Gosu::Image
  attr_reader :x, :y, :angle, :radius

  START_LOCATION = {x: 200, y: 200}
  SPEED_OF_ROTATION = 6
  ACCELERATION = 2
  FRICTION = 0.9
  RADIUS = 20

  def initialize(window)
    @x = START_LOCATION[:x]
    @y = START_LOCATION[:y]
    @image = super('images/ship.png')
    @angle = 0
    @velocity_x = 0
    @velocity_y = 0
    @window = window
    @radius = RADIUS
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

  def turn_right
    @angle += SPEED_OF_ROTATION
  end

  def turn_left
    @angle -= SPEED_OF_ROTATION
  end

  def accelerate
    @velocity_x += Gosu.offset_x(@angle, ACCELERATION)
    @velocity_y += Gosu.offset_y(@angle, ACCELERATION)
  end

  def move
    @x += @velocity_x
    @y += @velocity_y
    @velocity_x *= FRICTION
    @velocity_y *= FRICTION

    if @x > @window.width - @radius
      @velocity_x = 0
      @x = @window.width - @radius
    elsif @x < @radius
      @velocity_x = 0
      @x = @radius
    end

    if @y > @window.height - @radius
      @velocity_y = 0
      @y = @window.height - @radius
    end
  end
end
