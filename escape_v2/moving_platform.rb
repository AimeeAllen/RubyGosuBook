class MovingPlatform
  WIDTH = 96
  HEIGHT = 16
  FRICTION = 0.7
  ELASTICITY = 0.8
  SPEED_LIMIT = 40
  HORIZONTAL_FORCE = 20_000_000
  VERTICAL_FORCE = 5_000_000

  attr_reader :body, :width, :height

  def initialize(window, x, y, range, direction)
    space = window.space
    @window = window #
    @x_centre = x
    @y_centre = y
    @width = WIDTH
    @height = HEIGHT
    @direction = direction # :horizontal or :vertical
    @range = range
    @body = CP::Body.new(50_000, 100.0/0) # mass, rotational inertia
    @body.v_limit = SPEED_LIMIT
    if @direction == :horizontal
      @body.p = CP::Vec2.new(x + range + 100, y)
      @move = :right
    else
      @body.p = CP::Vec2.new(x, y + range + 100)
      @move = :down
    end
    bounds = [CP::Vec2.new(-WIDTH/2, -HEIGHT/2),
      CP::Vec2.new(-WIDTH/2, HEIGHT/2),
      CP::Vec2.new(WIDTH/2, HEIGHT/2),
      CP::Vec2.new(WIDTH/2, -HEIGHT/2)]
    shape = CP::Shape::Poly.new(@body, bounds, CP::Vec2.new(0,0))
    shape.u = FRICTION
    shape.e = ELASTICITY
    space.add_body(@body)
    space.add_shape(shape)
    @image = Gosu::Image.new('images/platform.png')
    counter_gravity
  end

  def counter_gravity
    @body.apply_force(CP::Vec2.new(0, -20_000_000), CP::Vec2.new(0,0))
  end

  def move
    case @direction
    when :horizontal
      if @body.p.x < @x_centre - @range && @move == :left
        @body.reset_forces
        counter_gravity
        @body.apply_force(CP::Vec2.new(HORIZONTAL_FORCE, 0), CP::Vec2.new(0,0))
        @move = :right
      elsif @body.p.x > @x_centre + @range && @move == :right
        @body.reset_forces
        counter_gravity
        @body.apply_force(CP::Vec2.new(-HORIZONTAL_FORCE,0), CP::Vec2.new(0,0))
        @move = :left
      end
      @body.p.y = @y_centre
    when :vertical
      if @body.p.y > @y_centre + @range && @move == :down
        @body.reset_forces
        counter_gravity
        @body.apply_force(CP::Vec2.new(0, -VERTICAL_FORCE), CP::Vec2.new(0,0))
        @move = :up
      elsif @body.p.y < @y_centre - @range && @move == :up
        @body.reset_forces
        counter_gravity
        @body.apply_force(CP::Vec2.new(0, VERTICAL_FORCE), CP::Vec2.new(0,0))
        @move = :down
      end
      @body.p.x = @x_centre      
    end
  end

  def draw
    @image.draw_rot(@body.p.x, @body.p.y, 0, 1)
  end
end