require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'

class SectorFive < Gosu::Window
  WIDTH = 800
  HEIGHT = 600
  ENEMY_FREQUENCY = 0.01

  def initialize
    super(WIDTH, HEIGHT)
    self.caption = 'Sector Five'
    @player = Player.new(self)
    @enemies = []
    @bullets = []
    @explosions = []
  end

  def draw
    @player.draw
    @enemies.each {|enemy| enemy.draw}
    @bullets.each {|bullet| bullet.draw}
    @explosions.each do |explosion|
      explosion.draw
    end
  end

  def update
    @player.turn_left if button_down?(Gosu::KbLeft)
    @player.turn_right if button_down?(Gosu::KbRight)
    @player.accelerate if button_down?(Gosu::KbUp)
    @player.move
    @bullets.each {|bullet| bullet.move}
    if rand < ENEMY_FREQUENCY
      @enemies.push(Enemy.new(self))
    end
    @enemies.each {|enemy| enemy.move}

    @enemies.dup.each do |enemy|
      @bullets.dup.each do |bullet|
        distance_between = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
        if distance_between <= (enemy.radius + bullet.radius)
          @bullets.delete bullet #deletes from original array, continue to iterate over dup
          @enemies.delete enemy
          @explosions.push(Explosion.new(self, enemy.x, enemy.y))
        else
          @bullets.delete bullet unless bullet.on_screen?
          @enemies.delete enemy unless enemy.y < (self.height + enemy.radius)
        end
      end
    end
    @explosions.dup.each do |explosion|
      @explosions.delete(explosion) if explosion.finished
    end

  end

  def button_down(id)
    @bullets.push Bullet.new(self, @player.x, @player.y, @player.angle) if id == Gosu::KbSpace
  end

end

window = SectorFive.new
window.show
