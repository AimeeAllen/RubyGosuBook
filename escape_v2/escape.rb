require 'gosu'
require 'chipmunk'
require_relative 'boulder'
require_relative 'platform'
require_relative 'moving_platform'
require_relative 'wall'
require_relative 'chip'
require_relative 'camera'

class Escape < Gosu::Window
  WINDOW_SIZE = 800
  SPACE_SIZE = WINDOW_SIZE * 2
  DAMPING = 0.9
  GRAVITY = 400.0
  BACKGROUND_HEIGHT = 529
  BACKGROUND_WIDTH = 799
  BOULDER_FREQUENCY = 0.01
  WALL_WIDTH = 20
  FLURO_GREEN = 0xff00ff00
  BLUE = 0xff2e21c1
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
    @floor = Wall.new(self, SPACE_SIZE/2, SPACE_SIZE + WALL_WIDTH/2, SPACE_SIZE, WALL_WIDTH)
    @left_wall = Wall.new(self, -WALL_WIDTH/2, SPACE_SIZE/2, WALL_WIDTH, SPACE_SIZE)
    @right_wall = Wall.new(self, SPACE_SIZE + WALL_WIDTH/2, (SPACE_SIZE-140)/2 + 140, WALL_WIDTH, (SPACE_SIZE-140))
    @player = Chip.new(self, 70, SPACE_SIZE-Chip::HEIGHT/2)
    @sign = Gosu::Image.new('images/exit.png')
    @game_time_sec = 0
    @font = Gosu::Font.new(40)
    @font_small = Gosu::Font.new(18)
    @music = Gosu::Song.new('sounds/zanzibar.ogg')
    @music.play(true)
    @camera = Camera.new(self, SPACE_SIZE, SPACE_SIZE)
    @quake_time = 0
    @quake_sound = Gosu::Sample.new('sounds/quake.ogg')
  end

  def draw
    @camera.view do
      (0..3).each do |row|
        (0..1).each do |column|
          @background.draw(column * BACKGROUND_WIDTH, row * BACKGROUND_HEIGHT,0)
        end
      end
      @boulders.each {|boulder| boulder.draw}
      @platforms.each {|platform| platform.draw}
      @player.draw
      @sign.draw(SPACE_SIZE*0.9,20,2)
    end

    if @game_over == false
      @font.draw("Time taken: #{@game_time_sec} seconds", 20,20,3,1,1, BLUE)
    else
      @font.draw("Time taken: #{@win_time} seconds", 20,20,3,1,1, BLUE)
      draw_credits
    end
  end

  def draw_credits
    colour = BLUE
    @font.draw("GAME OVER!", 170, 150, 3, 2, 2, colour)
    credits = ['Images from the SpriteLib Collection',
      'by WidgetWorx under the terms of the',
      'Common Public License.',
      'Music: Zanzibar, by Kevin MacLeod',
      '(incompetech.com)',
      'Licensed under',
      'Creative Commons: By Attribution 3.0',
      'http://creativecommons.org/licenses/by/3.0/']
    credits.each_with_index do |line, i|
      @font_small.draw(line, 90, 300 + 50 * i, 3,2,2, colour)
    end
  end

  def update
    @camera.centre_on(@player, self.width/2, self.height/4)
    unless @game_over
      @game_time_sec = Gosu.milliseconds/1000.to_i
      10.times do
        @space.step(1.0/600)
      end
      if rand <= BOULDER_FREQUENCY
        create_new_boulder
      end

      @platforms.each do |platform|
        platform.move if platform.respond_to? (:move)
      end

      if rand < 0.001
        start_quake
      end
      @quake_time -= 1
      if @quake_time > 0
        @camera.shake
        create_new_boulder if rand < 0.2
      end

      @player.check_footing(@boulders + @platforms + [@floor])

      if button_down?(Gosu::KbRight)
        @player.move_right
      elsif button_down?(Gosu::KbLeft)
        @player.move_left
      else
        @player.stand
      end

      if @player.x > SPACE_SIZE
        @game_over = true
        @win_time = @game_time_sec
      end
    end
  end

  def create_new_boulder
    @boulders.push Boulder.new(self, rand(SPACE_SIZE/8..SPACE_SIZE*7/8), -20)
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
    platforms = []
    (0..10).each do |row|
      (0..4).each do |column|
        x = column*300 + 200
        y = row*140 + 100
        x -= 150 if row%2==0
        x += rand(-50..50)
        y += rand(-50..50)
        num = rand
        if num < 0.4
          direction = rand < 0.5 ? :vertical : :horizontal
          range = 30 + rand(40)
          platforms.push MovingPlatform.new(self,x,y,range,direction)
        elsif num < 0.9
          platforms.push Platform.new(self,x,y)
        end
      end
    end
    platforms.push Platform.new(self,SPACE_SIZE-50,140)
    platforms
  end

  def start_quake
    @quake_time = 30
    @quake_sound.play
    @boulders.each do |boulder|
      boulder.quake
    end
  end
end

window = Escape.new
window.show
