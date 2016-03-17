class Square
  SQUARE_START = 22
  SQUARE_WIDTH = 96
  BORDER_PLUS_SQUARE_WIDTH = 100
  FONT_HEIGHT = 72
  HIGHLIGHT_WIDTH = 4

  attr_reader :row, :column, :number, :colour
  def initialize(row, column, colour, window)
    @@window ||= window
    @@colours ||= {red: Gosu::Color.argb(0xaaff0000),
                  green: Gosu::Color.argb(0xaa00ff00),
                  blue: Gosu::Color.argb(0xaa0000ff)}
    @@font ||= Gosu::Font.new(FONT_HEIGHT)

    @row = row
    @column = column
    @colour = colour
    @number = 1
  end

  def draw
    if @number > 0
      x1 = SQUARE_START + BORDER_PLUS_SQUARE_WIDTH * @column
      y1 = SQUARE_START + BORDER_PLUS_SQUARE_WIDTH * @row
      x2 = x1 + SQUARE_WIDTH
      y2 = y1
      x3 = x2
      y3 = y2 + SQUARE_WIDTH
      x4 = x1
      y4 = y3
      c = @@colours[@colour]
      @@window.draw_quad(x1, y1, c, x2, y2, c, x3, y3, c, x4, y4, c, 2)
      x_centre = x1 + SQUARE_WIDTH/2
      x_font = x_centre - @@font.text_width("#{@number}")/2
      y_font = y1 + SQUARE_WIDTH/2 - FONT_HEIGHT/2
      @@font.draw(@number, x_font, y_font, 1)
    end
  end

  def set(colour, number)
    @colour = colour
    @number = number
  end

  def clear
    @number = 0
  end

  def highlight(state)
    case state
    when :start then colour = Gosu::Color::WHITE
    when :legal then colour = Gosu::Color::GREEN
    when :illegal then colour = Gosu::Color::RED
    end
    x1 = SQUARE_START + BORDER_PLUS_SQUARE_WIDTH * @column
    y1 = SQUARE_START + BORDER_PLUS_SQUARE_WIDTH * @row

    distance_between_highlights = SQUARE_WIDTH - HIGHLIGHT_WIDTH
    draw_horizontal_highlight(x1, y1, colour)
    draw_horizontal_highlight(x1, y1 + distance_between_highlights, colour)
    draw_vertical_highlight(x1, y1, colour)
    draw_vertical_highlight(x1 + distance_between_highlights, y1, colour)
  end

  def draw_horizontal_highlight(x1, y1, c)
    @@window.draw_quad(x1, y1, c,
                     x1 + SQUARE_WIDTH, y1, c,
                     x1 + SQUARE_WIDTH, y1 + HIGHLIGHT_WIDTH, c,
                     x1, y1 + HIGHLIGHT_WIDTH, c,
                     3)
  end

  def draw_vertical_highlight(x1, y1, c)
    @@window.draw_quad(x1, y1, c,
                     x1 + HIGHLIGHT_WIDTH, y1, c,
                     x1 + HIGHLIGHT_WIDTH, y1 + SQUARE_WIDTH, c,
                     x1, y1 + SQUARE_WIDTH, c,
                     3)
  end
end