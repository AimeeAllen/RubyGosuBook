require 'gosu'

WINDOW_SIZE = { x: 800, y: 600}
RUBY_IMAGE_SIZE = { x: 50, y: 43}
HAMMER_IMAGE_SIZE = { x: 80, y: 20}
FONT_SIZE = 30
SCORE_POSITION = {x: 570, y: 20}
TIME_VISABLE = 60
POINTS_FOR_HIT = 5
GAME_LENGTH_SEC = 30

class Image < Gosu::Image
  attr_accessor :x, :y, :width, :height, :velocity_x, :velocity_y, :visable
  def initialize(file_location, x, y, width, height, velocity_x = 0, velocity_y = 0, visable = 0)
    super(file_location)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.velocity_x = velocity_x
    self.velocity_y = velocity_y
    self.visable = visable
  end

  def top_corner_x
    self.x - self.width/2
  end

  def top_corner_y
    self.y - self.height/2
  end

  def move
    self.velocity_x *= -1 unless (0..WINDOW_SIZE[:x]-self.width).include?(self.top_corner_x)
    self.velocity_y *= -1 unless (0..WINDOW_SIZE[:y]-self.height).include?(self.top_corner_y)
    self.x += velocity_x
    self.y += velocity_y
  end
end

class WhackARuby < Gosu::Window
  def initialize
    super(WINDOW_SIZE[:x], WINDOW_SIZE[:y])
    self.caption = "Aimee's Whack-A-Ruby"
    @ruby = Image.new('images/ruby.png', 400, 300, RUBY_IMAGE_SIZE[:x], RUBY_IMAGE_SIZE[:y], 7, 5)
    @ruby2 = Image.new('images/ruby.png', 600, 450, RUBY_IMAGE_SIZE[:x], RUBY_IMAGE_SIZE[:y], 1, 1)
    @hammer = Image.new('images/hammer.png', mouse_x, mouse_y, HAMMER_IMAGE_SIZE[:x], HAMMER_IMAGE_SIZE[:y])
    @hit = 0
    @font = Gosu::Font.new(FONT_SIZE)
    @score = 0
    @start_time = 0
    @playing = true
  end

  def update
    if @playing
      [@ruby, @ruby2].each do |image|
        image.move
        image.visable -= 1
        image.visable = TIME_VISABLE if image.visable < -10 && rand < 0.01
      end
      @hammer.x = mouse_x
      @hammer.y = mouse_y
      @time_left = GAME_LENGTH_SEC - (Gosu.milliseconds/1000 - @start_time)
      @playing = false if @time_left < 0
      #@ruby2.visable = TIME_VISABLE
    end
  end

  def button_down(id)
    if @playing && id == Gosu::MsLeft
      if Gosu.distance(@hammer.x, @hammer.y, @ruby.x, @ruby.y) < 50 && @ruby.visable >= 0
        @hit = 1
        @score += POINTS_FOR_HIT
      elsif Gosu.distance(@hammer.x, @hammer.y, @ruby2.x, @ruby2.y) < 50 && @ruby2.visable >= 0
        @hit = 1
        @score += POINTS_FOR_HIT
      else
        @hit = -1
        @score -= 1
      end
    end
    if !@playing && id == Gosu::KbSpace
      @score = 0
      @playing = true
      [@ruby, @ruby2].each {|image| image.visable = -10}
      @start_time = Gosu.milliseconds/1000
    end
  end

  def draw
    [@ruby, @ruby2, @hammer].each do |image|
      image.draw(image.top_corner_x, image.top_corner_y, 1) if image.visable >= 0
    end

    if @hit == 1
      background_colour = Gosu::Color::GREEN
    elsif @hit == -1
      background_colour = Gosu::Color::RED
    else
      background_colour = Gosu::Color::NONE
    end

    draw_quad(0, 0, background_colour,
      WINDOW_SIZE[:x], 0, background_colour,
      WINDOW_SIZE[:x], WINDOW_SIZE[:y], background_colour,
      0, WINDOW_SIZE[:y], background_colour)
    @hit = 0

    @font.draw("Your Score: #{@score}", SCORE_POSITION[:x], SCORE_POSITION[:y], 2)

    if @playing
      @font.draw("Time Left: #{@time_left}", FONT_SIZE, SCORE_POSITION[:y], 2)
    else
      Gosu::Font.new(100).draw("GAME OVER!", 100, 200, 3)
      [@ruby, @ruby2, @hammer].each {|image| image.visable = TIME_VISABLE}
      @font.draw('Press the spacebar to play again!', 180, 400, 3)
    end

  end
end

window = WhackARuby.new
window.show
