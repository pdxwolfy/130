# This class represents a collection of Todo objects.
# You can perform typical collection-oriented actions
# on a TodoList object, including iteration and selection.

class TodoList
  attr_accessor :title

  def initialize(title)
    @title = title
    @todos = []
  end

  def <<(todo)
    raise TypeError, 'Can only add Todo objects' unless todo.instance_of? Todo
    @todos << todo
    self
  end

  alias add <<

  def all_done
    select { |todo| todo.done? }
  end

  def all_not_done
    select { |todo| !todo.done? }
  end

  def done?
    @todos.all? { |todo| todo.done? }
  end

  def done!
    each { |todo| todo.done! }
  end

  def each
    return to_enum :each unless block_given?
    @todos.each { |todo| yield todo }
    self
  end

  def find_by_title(title)
    select { |todo| todo.title == title }&.first
  end

  def first
    @todos.first
  end

  def item_at(index)
    @todos.fetch(index)
  end

  def last
    @todos.last
  end

  alias mark_all_done done!

  def mark_all_undone
    each { |todo| todo.undone! }
  end

  def mark_done(title)
    find_by_title(title)&.done!
  end

  def mark_done_at(index)
    item_at(index).done!
  end

  def mark_undone_at(index)
    item_at(index).undone!
  end

  def pop
    @todos.pop
  end

  def remove_at(index)
    @todos.fetch(index) # force IndexError exception if needed.
    @todos.delete_at(index)
  end

  def select
    return to_enum :select unless block_given?
    result = TodoList.new(title)
    @todos.each { |todo| result << todo if yield todo }
    result
  end

  def shift
    @todos.shift
  end

  def size
    @todos.size
  end

  def to_a
    @todos
  end

  def to_s
    %(---- #{title} ----\n#{@todos.map(&:to_s).join "\n"})
  end

  alias undone! mark_all_undone
end
