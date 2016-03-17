require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'credit'

class SectorFive < Gosu::Window
  WIDTH = 800
  HEIGHT = 600
  ENEMY_FREQUENCY = 0.01
  MAX_ENEMIES = 100

  def initialize
    super(WIDTH, HEIGHT)
    self.caption = 'Sector Five'
    @background_image = Gosu::Image.new('images/start_screen.png')
    @scene = :start
    @start_music = Gosu::Song.new('sounds/Lost Frontier.ogg')
    @start_music.play(true)
  end

  def initialize_game
    @player = Player.new(self)
    @enemies = []
    @bullets = []
    @explosions = []
    @scene = :game
    @enemies_appeared = 0
    @enemies_destroyed = 0
    @game_music = Gosu::Song.new('sounds/Cephalopod.ogg')
    @game_music.play(true)
    @player_hit = false
    @explosion_sound = Gosu::Sample.new('sounds/explosion.ogg')
    @shooting_sound = Gosu::Sample.new('sounds/shoot.ogg')
    @score_font = Gosu::Font.new(40)
  end

  def initialize_end(condition)
    @scene = :end
    @message_font = Gosu::Font.new(28)
    case condition
    when :count_reached
      @message = "Congratulations - you survived."
      @message2 = "You destroyed #{@enemies_destroyed} enemy ships, " +
        "and #{MAX_ENEMIES - @enemies_destroyed} enemies made it through."
    when :hit_by_enemy
      @message = "You have collided with an enemy ship."
      @message2 = "You destroyed #{@enemies_destroyed} enemy ships, " +
        "before you're ship was destroyed"
    when :off_top
      @message = "You flew too close to the enemy mothership."
      @message2 = "You destroyed #{@enemies_destroyed} enemy ships, " +
        "before you're ship was destroyed"
    end
    @bottom_message = "Press P to play again or Q to quit."

    @credits = []
    y = 700

    File.open('credits.txt').each do |line|
      @credits.push Credit.new(self, 100, y, line.chomp)
      y += 30
    end  

    @end_music = Gosu::Song.new('sounds/FromHere.ogg')
    @end_music.play(true)  
  end

  def draw
    case @scene
    when :start
      draw_start
    when :game
      draw_game
    when :end
      draw_end
    end
  end

  def draw_start
    @background_image.draw(0, 0, 0)
  end

  def draw_game
    @player.draw
    @enemies.each {|enemy| enemy.draw}
    @bullets.each {|bullet| bullet.draw}
    @explosions.each do |explosion|
      explosion.draw
    end
    @score_font.draw("Destroyed Enemies: #{@enemies_destroyed}",385,15,2)
  end

  def draw_end
    @message_font.draw(@message, 150, 40, 1, 1, 1, Gosu::Color::FUCHSIA)
    @message_font.draw(@message2, 10, 75, 1, 1, 1, Gosu::Color::FUCHSIA)
    draw_line(0,140,Gosu::Color::RED, WIDTH,140,Gosu::Color::RED)
    clip_to(50,140,700,360) do
      @credits.each {|credit| credit.draw}
    end
    draw_line(0,500,Gosu::Color::RED, WIDTH,500,Gosu::Color::RED)
    @message_font.draw(@bottom_message, 180, 540, 1, 1, 1, Gosu::Color::AQUA)
  end

  def update
    case @scene
    when :game
      update_game
    when :end
      update_end
    end
  end

  def update_game
    @player.turn_left if button_down?(Gosu::KbLeft)
    @player.turn_right if button_down?(Gosu::KbRight)
    @player.accelerate if button_down?(Gosu::KbUp)
    @player.move
    @bullets.each {|bullet| bullet.move}
    if rand < ENEMY_FREQUENCY
      @enemies.push(Enemy.new(self))
      @enemies_appeared += 1
    end
    @enemies.each {|enemy| enemy.move}

    @enemies.dup.each do |enemy|
      @bullets.dup.each do |bullet|
        distance_between = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
        if distance_between <= (enemy.radius + bullet.radius)
          @bullets.delete bullet #deletes from original array, continue to iterate over dup
          @enemies.delete enemy
          @explosions.push(Explosion.new(self, enemy.x, enemy.y))
          @enemies_destroyed += 1
          @explosion_sound.play
        else
          @bullets.delete bullet unless bullet.on_screen?
          @enemies.delete enemy unless enemy.y < (self.height + enemy.radius)
        end
      end
    end
    @explosions.dup.each do |explosion|
      @explosions.delete(explosion) if explosion.finished
    end

    @enemies.each do |enemy|
      distance_between = Gosu.distance(enemy.x, enemy.y, @player.x, @player.y)
      if distance_between < enemy.radius + @player.radius
        @player_hit = true
      else
        @player_hit = false
      end
    end

    initialize_end(@condition) if game_over?
  end

  def game_over?
    if @enemies_appeared > MAX_ENEMIES
      @condition = :count_reached
    elsif @player_hit
      @condition = :hit_by_enemy
    elsif @player.y < @player.radius
      @condition = :off_top
    else
      false
    end
  end

  def update_end
    if @credits.last.y < 150
      @credits.each {|credit| credit.reset}
    else
      @credits.each {|credit| credit.move}
    end
  end

  def button_down(id)
    case @scene
    when :start
      button_down_start(id)
    when :game
      button_down_game(id)
    when :end
      button_down_end(id)
    end
  end

  def button_down_start(id)
    initialize_game
  end

  def button_down_game(id)
    if id == Gosu::KbSpace
      @bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
      @shooting_sound.play(0.5)
    end
  end

  def button_down_end(id)
    if id == Gosu::KbP
      initialize_game
    elsif id == Gosu::KbQ
      close
    end
  end
end

window = SectorFive.new
window.show