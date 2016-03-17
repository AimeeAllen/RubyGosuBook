class Boulder
  SPEED_LIMIT = 500 # pixels per second
  FRICTION = 0.7
  ELASTICITY = 0.95
  BOULDER_RADIUS = 32
  RAD_TO_DEG = (180.0/Math::PI)
  START_FORCE = 100_000
  FORCE_FROM_CENTRE = 0.8
  attr_reader :body, :width, :height

  def initialize(window, x, y)
    @body = CP::Body.new(400,4000) # mass, rotational inertia
    @body.p = CP::Vec2.new(x, y)
    @body.v_limit = SPEED_LIMIT
    bounds = [CP::Vec2.new(-13,-10),
              CP::Vec2.new(-16,-4),
              CP::Vec2.new(-16,6),
              CP::Vec2.new(-3,12),
              CP::Vec2.new(8,12),
              CP::Vec2.new(13,10),
              CP::Vec2.new(16,3),
              CP::Vec2.new(16,-4),
              CP::Vec2.new(10,-9),
              CP::Vec2.new(2,-11)]
    shape = CP::Shape::Poly.new(@body, bounds, CP::Vec2.new(0,0)) # initial verlocity
    shape.u = FRICTION
    shape.e = ELASTICITY
    @width = BOULDER_RADIUS
    @height = BOULDER_RADIUS
    window.space.add_body(@body)
    window.space.add_shape(shape)
    @image = Gosu::Image.new('images/boulder.png')
    quake
  end

  def draw
    @image.draw_rot(@body.p.x, @body.p.y, 1, @body.angle * RAD_TO_DEG)
  end

  def quake
    @body.apply_impulse(CP::Vec2.new(rand(START_FORCE) - START_FORCE/2, START_FORCE),
          CP::Vec2.new(rand * FORCE_FROM_CENTRE - FORCE_FROM_CENTRE/2, 0))
  end
end