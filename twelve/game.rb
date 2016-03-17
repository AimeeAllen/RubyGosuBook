require_relative 'square'

class Game
  TEXT_SIZE = 36
  BORDER_WIDTH = 20

  attr_reader :square_states
  attr_accessor :squares

  def initialize(window)
    @window = window
    colour_list = []
    [:red, :green, :blue].each do |colour|
      12.times do
        colour_list.push colour
      end
    end
    colour_list.shuffle!
    @squares = []
    (0..5).each do |row|
      (0..5).each do |column|
        @squares << Square.new(row, column, colour_list.pop, @window)
      end
    end
    @font = Gosu::Font.new(TEXT_SIZE)
    @square_states = []
  end

  def draw
    @squares.each {|square| square.draw}
    if game_over?
      c = Gosu::Color.argb(0x33000000)
      @window.draw_quad(0, 0, c, @window.width, 0, c,
                        @window.width, @window.height, c,
                        0, @window.height, c, 4)
      @font.draw("GAME OVER", 230, 160, 5)
      @font.draw("There are no more legal moves!", 40, 240, 5)
      @font.draw("CTRL-R to Play Again", 205, 320, 5, 0.6, 0.6)
      @font.draw("CTRL-Q to Quit", 220, 370, 5, 0.6, 0.6)
    elsif @start_square
      @start_square.highlight(:start)
      if @current_square && @current_square != @start_square
        state = move_is_legal?(@start_square, @current_square) ? :legal : :illegal
        @current_square.highlight(state)
      end
    end
  end

  def game_over?
    @squares.each do |square|
      if legal_move_for?(square)
        return false
      end
    end
    return true
  end

  def move(square_1, square_2)
    # Note: move mutates game instance, it changes the state of certain squares
    # To make this reversible,
    # at the point just before the mutation opperation
    # you need to save a copy(clone) of each individual square
    # as clone(and dup) are only shallow copies
    # You can keep track of multiple states in this way by pushing them onto an array
    # and popping them off each time a certain button is pressed
    if squares = move_is_legal?(square_1, square_2)
      @squares_copy = @squares.map {|square| square.clone}
      @square_states.push @squares_copy
      colour = squares[0].colour
      new_number = squares[0].number + squares[1].number
      squares.each {|square| square.clear}
      square_2.set(colour, new_number)
    end
  end

  def move_is_legal?(square_1, square_2)
    if square_1.number > 0
      if square_1.row == square_2.row
        squares = squares_between(square_1, square_2, :row)
      elsif square_1.column == square_2.column
        squares = squares_between(square_1, square_2, :column)
      end
      if squares
        squares.delete_if {|square| square.number < 1}
        if squares.size == 2 && squares[0].colour == squares[1].colour
          return squares
        end
      end
    end
    return false
  end

  def legal_move_for?(start_square)
    return false if start_square.number < 1
    @squares.each do |square|
      if move_is_legal?(start_square, square)
        return true
      end
    end
    return false
  end

  def squares_between(square_1, square_2, shared_axis)
    case shared_axis
      when :row then different_axis = :column
      when :column then different_axis = :row
    end
    ordered_squares = [square_1.send(different_axis), square_2.send(different_axis)].sort
    start_value = ordered_squares[0]
    end_value = ordered_squares[1]
    squares = []
    (start_value..end_value).each do |value|
      square = shared_axis==:row ? get_square(value, square_1.row) : get_square(square_1.column, value)
      squares.push square
    end
    squares
  end

  def handle_mouse_down(x, y)
    column = find_column_or_row(x)
    row = find_column_or_row(y)
    @start_square = get_square(column, row)
  end

  def handle_mouse_up(x, y)
    column = find_column_or_row(x)
    row = find_column_or_row(y)
    @end_square = get_square(column, row)
    if @start_square and @end_square
      move(@start_square, @end_square)
    end
    @start_square = nil
  end

  def handle_mouse_move(x, y)
    column = find_column_or_row(x)
    row = find_column_or_row(y)
    @current_square = get_square(column, row)
  end

  def find_column_or_row(x_or_y)
    (x_or_y.to_i - BORDER_WIDTH)/Square::BORDER_PLUS_SQUARE_WIDTH
  end

  def get_square(column, row)
    if (0..5).include?(row) && (0..5).include?(column)
      square = @squares.map {|m| m if m.row == row && m.column == column}
      square.delete_if {|m| m == nil}
      square.first
    else
      nil
    end
  end
end