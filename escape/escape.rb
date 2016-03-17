require 'gosu'
require 'chipmunk'
require_relative 'boulder'
require_relative 'platform'
require_relative 'moving_platform'
require_relative 'wall'
require_relative 'chip'

class Escape < Gosu::Window
  WINDOW_SIZE = 800
  DAMPING = 0.9
  GRAVITY = 400.0
  BACKGROUND_HEIGHT = 529
  BOULDER_FREQUENCY = 0.01
  WALL_WIDTH = 20
  FLURO_GREEN = 0xff00ff00
  attr_reader :space
	
	def initialize
		super WINDOW_SIZE,WINDOW_SIZE,false
    self.caption = "Escape"
    @space = CP::Space.new
    @game_over = false
    @background = Gosu::Image.new('images/background.png', tileable: true)
    @space.damping = DAMPING
    @space.gravity = CP::Vec2.new(0.0, GRAVITY)
    @boulders = []
    @platforms = make_platforms
    @floor = Wall.new(self, WINDOW_SIZE/2, WINDOW_SIZE + WALL_WIDTH/2, WINDOW_SIZE, WALL_WIDTH)
    @left_wall = Wall.new(self, -WALL_WIDTH/2, WINDOW_SIZE/2, WALL_WIDTH, WINDOW_SIZE)
    @right_wall = Wall.new(self, WINDOW_SIZE + WALL_WIDTH/2, (WINDOW_SIZE-140)/2 + 140, WALL_WIDTH, (WINDOW_SIZE-140))
    @player = Chip.new(self, 70, WINDOW_SIZE-Chip::HEIGHT/2)
    @sign = Gosu::Image.new('images/exit.png')
    @game_time_sec = 0
    @font = Gosu::Font.new(40)
  end

  def draw
    @background.draw(0,0,0)
    @background.draw(0, BACKGROUND_HEIGHT, 0)
    @boulders.each {|boulder| boulder.draw}
    @platforms.each {|platform| platform.draw}
    @player.draw
    @sign.draw(680,20,1)
    if @game_over == false
      @font.draw("Time taken: #{@game_time_sec} seconds", 20,20,3,1,1, FLURO_GREEN)
    else
      @font.draw("Time taken: #{@win_time} seconds", 20,20,3,1,1, FLURO_GREEN)
      @font.draw("GAME OVER!", 200, 300, 3, 2, 2, FLURO_GREEN)
    end
  end

  def update
    unless @game_over
      10.times do
        @space.step(1.0/600)
      end
    end
    if rand <= BOULDER_FREQUENCY
      @boulders.push Boulder.new(self, rand(self.width/4..self.width*3/4), -20)
    end

    @platforms.each do |platform|
      platform.move if platform.respond_to? (:move)
    end

    @player.check_footing(@boulders + @platforms + [@floor])

    if button_down?(Gosu::KbRight)
      @player.move_right
    elsif button_down?(Gosu::KbLeft)
      @player.move_left
    else
      @player.stand
    end

    @game_time_sec = Gosu.milliseconds/1000.to_i

    if @player.x > WINDOW_SIZE && @game_over == false
      @game_over = true
      @win_time = @game_time_sec
    end
  end

  def button_down(id)
    if id == Gosu::KbSpace
      @player.jump
    end
    if id == Gosu::KbQ
      close
    end
  end

  def make_platforms
    static_co_ordinates = [[150,700],[320,650],[150,500],[470,550],
      [320,440],[600,150],[700,450],[580,300],[750,140],[700,700]]
    moving_parameters = [[580,600,70,:vertical],
      [190,330,50,:vertical],
      [450,230,70,:horizontal]]
    platforms = []
    static_co_ordinates.each do |co|
      platforms.push Platform.new(self, co[0], co[1])
    end
    moving_parameters.each do |p|
      platforms.push MovingPlatform.new(self, p[0], p[1], p[2], p[3])
    end
    platforms
  end

end

window = Escape.new
window.show
