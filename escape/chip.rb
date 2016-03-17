class Chip
  MASS = 50
  HEIGHT = 64
  WIDTH = 20
  FRICTION = 0.7
  ELASTICITY = 0.2
  RUN_IMPULSE = 600
  JUMP_IMPULSE = 36000
  FLY_IMPULSE = 60
  AIR_JUMP_IMPULSE = 1200
  SPEED_LIMIT = 400

  attr_accessor :off_ground
  #attr_reader :body

  def initialize(window, x, y)
    @window = window
    space = window.space
    @images = Gosu::Image.load_tiles('images/chip.png', 40, 65)
    @body = CP::Body.new(MASS, 100.0/0) #infinite rotational innertia = won't rotate
    @body.p = CP::Vec2.new(x,y)
    @body.v_limit = SPEED_LIMIT
    bounds = [CP::Vec2.new(-WIDTH/2,-HEIGHT/2),
      CP::Vec2.new(-WIDTH/2,HEIGHT/2),
      CP::Vec2.new(WIDTH/2,HEIGHT/2),
      CP::Vec2.new(WIDTH/2,-HEIGHT/2)]
    shape = CP::Shape::Poly.new(@body, bounds, CP::Vec2.new(0,0))
    shape.u = FRICTION
    shape.e = ELASTICITY
    space.add_body(@body)
    space.add_shape(shape)

    @action = :stand #other options :run_right, :run_left, :jump_left, :jump_right
    @off_ground = true
    @image_index = 0 #sequence of images for action
  end

  def x
    @body.p.x
  end

  def draw
    case @action
      when :stand, :jump_right
        @images[0].draw_rot(@body.p.x, @body.p.y, 2, 0)
      when :run_right
        @images[@image_index].draw_rot(@body.p.x, @body.p.y, 2, 0)
        @image_index = (@image_index + 0.2) %8
      when :run_left
        # x, y, z, angle, centre_x=0.5, centre_y=0.5, scale_x=1, scale_y=1
        @images[@image_index].draw_rot(@body.p.x, @body.p.y, 2, 0, 0.5, 0.5, -1, 1)
        @image_index = (@image_index + 0.2) %8
      when :jump_left
        @images[0].draw_rot(@body.p.x, @body.p.y, 2, 0, 0.5, 0.5, -1, 1)
    end
  end

  def touching?(footing)
    x_diff = (@body.p.x - footing.body.p.x).abs
    y_diff = (@body.p.y + 30 - footing.body.p.y).abs
    x_diff < 12 + footing.width/2 and y_diff < 5 + footing.height / 2
  end

  def check_footing(things)
    @off_ground = true
    things.each do |thing|
      @off_ground = false if touching?(thing)
    end
  end

  def move_left
    if @off_ground
      @action = :jump_left
      @body.apply_impulse(CP::Vec2.new(-FLY_IMPULSE, 0), CP::Vec2.new(0,0))
    else
      @action = :run_left
      @body.apply_impulse(CP::Vec2.new(-RUN_IMPULSE, 0), CP::Vec2.new(0,0))
    end
  end

  def move_right
    if @off_ground
      @action = :jump_right
      @body.apply_impulse(CP::Vec2.new(FLY_IMPULSE, 0), CP::Vec2.new(0,0))
    else
      @action = :run_right
      @body.apply_impulse(CP::Vec2.new(RUN_IMPULSE, 0), CP::Vec2.new(0,0))
    end
  end

  def stand
    @action = :stand unless off_ground
  end

  def jump
    if @off_ground
      @body.apply_impulse(CP::Vec2.new(0, - AIR_JUMP_IMPULSE), CP::Vec2.new(0,0))
    else
      @body.apply_impulse(CP::Vec2.new(0, -JUMP_IMPULSE), CP::Vec2.new(0,0))
      if @action == :run_left
        @action = :jump_left
      else
        @action = :jump_right
      end
    end
  end
end