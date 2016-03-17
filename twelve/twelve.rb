require 'gosu'
require_relative 'game'

class Twelve < Gosu::Window
  SIDE_LENGTH = 640
  BORDER_WIDTH = 20
  def initialize
    super(SIDE_LENGTH, SIDE_LENGTH)
    self.caption = "Twelve"
    @game = Game.new(self)
  end

  def draw
    @game.draw
  end

  def needs_cursor?
    true
  end

  def update
    if button_down?(Gosu::KbR) && button_down?(Gosu::KbLeftControl)
      @game = Game.new(self)
    end
    if button_down?(Gosu::KbQ) && button_down?(Gosu::KbLeftControl)
      close
    end
    @game.handle_mouse_move(mouse_x, mouse_y)
  end

  def button_down(id)
    if id == Gosu::MsLeft
      @game.handle_mouse_down(mouse_x, mouse_y)
    end
    if id == Gosu::KbU && button_down?(Gosu::KbLeftControl)
      # Undo the last move
      @game.squares = @game.square_states.pop unless @game.square_states.empty?
    end
  end

  def button_up(id)
    if id == Gosu::MsLeft
      @game.handle_mouse_up(mouse_x, mouse_y)
    end
  end
end

window = Twelve.new
window.show