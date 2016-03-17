class Camera
  attr_reader :x_offset, :y_offset
  def initialize(window, space_height, space_width)
    @window = window
    @window_width = window.width
    @window_height = window.height
    @space_height = space_height
    @space_width = space_width
    @max_x_offset = @space_width - @window_width
    @max_y_offset = @space_height - @window_height
  end

  def centre_on(sprite, right_margin, bottom_margin)
    @x_offset = sprite.x + right_margin - @window.width
    @y_offset = sprite.y + bottom_margin - @window_height

    @x_offset = @max_x_offset if @x_offset > @max_x_offset
    @x_offset = 0 if @x_offset < 0
    @y_offset = @max_y_offset if @y_offset > @max_y_offset
    @y_offset = 0 if @y_offset < 0
  end

  def view # takes a block of objects to draw
    @window.translate(-@x_offset, -@y_offset) do
      yield      
    end
  end

  def shake
    @x_offset += rand(9)-4
    @y_offset += rand(9)-4
  end
end