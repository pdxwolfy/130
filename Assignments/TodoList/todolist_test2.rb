require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

## rubocop:disable MethodLength

require_relative 'todo'
require_relative 'todolist'

#------------------------------------------------------------------------------

describe Todo do
  make_my_diffs_pretty!

  class DerivedTodo < Todo; end

  before do
    @todo1 = Todo.new 'Item title', 'Item description'
    @todo2 = Todo.new 'Item title2'
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#initialize' do
    it 'sets initial title' do
      @todo1.title.must_equal 'Item title'
    end

    it 'sets initial description with non-default description' do
      @todo1.description.must_equal 'Item description'
    end

    it 'sets initial description with default description' do
      @todo2.description.must_equal ''
    end

    it 'sets initial undone state' do
      @todo1.done.must_equal false
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#title=' do
    it 'sets title' do
      @todo1.title = 'Abc'
      @todo1.title.must_equal 'Abc'
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#description=' do
    it 'sets description' do
      @todo1.description = 'Abc'
      @todo1.description.must_equal 'Abc'
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#done=' do
    it 'can sets done' do
      @todo1.done = true
      @todo1.done.must_equal true
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#done!' do
    it 'marks done' do
      @todo1.done!
      @todo1.done.must_equal true
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#undone!' do
    it 'marks undone' do
      @todo2.done!
      @todo2.undone!
      @todo2.done.must_equal false
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#done?' do
    it 'queries done state' do
      @todo1.wont_be :done?
      @todo1.done!
      @todo1.must_be :done?
      @todo1.undone!
      @todo1.wont_be :done?
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#to_s' do
    it 'converts to string when not done' do
      @todo1.to_s.must_equal '[ ] Item title'
      @todo2.to_s.must_equal '[ ] Item title2'
    end

    it 'converts to string when done' do
      @todo1.done!
      @todo2.done!
      @todo1.to_s.must_equal '[X] Item title'
      @todo2.to_s.must_equal '[X] Item title2'
    end

    it 'works when using undone!' do
      @todo1.done!
      @todo2.done!
      @todo1.undone!
      @todo2.undone!
      @todo1.to_s.must_equal '[ ] Item title'
      @todo2.to_s.must_equal '[ ] Item title2'
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  # Monkey-patched == method

  describe '#==' do
    it 'is true when all attributes are the same' do
      new_todo = Todo.new(@todo1.title, @todo1.description)
      @todo1.must_equal new_todo
    end

    it 'is false if the title is different' do
      new_todo = Todo.new(@todo1.title + 'x', @todo1.description)
      @todo1.wont_equal new_todo
    end

    it 'is false if the description is different' do
      new_todo = Todo.new(@todo1.title, @todo1.description + 'x')
      @todo1.wont_equal new_todo
    end

    it 'is false if the done state is different' do
      new_todo = Todo.new(@todo1.title, @todo1.description)
      new_todo.done!
      @todo1.wont_equal new_todo
    end

    it 'is false if the other object is not a Todo object' do
      new_todo = DerivedTodo.new(@todo1.title, @todo1.description)
      @todo1.wont_equal new_todo
      3.wont_equal new_todo
      'Item title'.wont_equal new_todo
    end
  end
end

#------------------------------------------------------------------------------

describe TodoList do
  make_my_diffs_pretty!

  class DerivedTodo < Todo; end

  before do
    @title = "Today's Todos"
    tasks = ['Buy milk', 'Clean room', 'Go to gym']
    todos = tasks.map { |task| Todo.new task }

    @todo1, @todo2, @todo3 = @todos1 = todos.map(&:clone)
    @list1 = TodoList.new @title.clone
    @todos1.each { |todo| @list1.add todo.clone }

    @todos2 = todos.map(&:clone)
    @list2 = TodoList.new @title.clone
    @todos2.each { |todo| @list2 << todo.clone }

    @todo1done = @todo1.clone
    @todo2done = @todo2.clone
    @todo3done = @todo3.clone
    @todo1done.done!
    @todo2done.done!
    @todo3done.done!

    @work = TodoList.new 'My Todo List'
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#initialize' do
    it 'sets initial title' do
      @list1.title.must_equal @title
    end

    it 'sets initial empty todo array' do
      @work.to_a.must_be_empty
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#title=' do
    it 'sets title' do
      @list1.title = 'Abc Def'
      @list1.title.must_equal 'Abc Def'
    end

    it 'does not modify the list of Todos' do
      @list1.title
      @list1.to_a.must_equal [@todo1, @todo2, @todo3]
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#to_a' do
    it 'can convert populated list to array of Todos' do
      @list1.to_a.must_equal @todos1
    end

    it 'can convert empty list to empty array' do
      @work.to_a.must_be_empty
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#size' do
    it 'can determine populated list size' do
      @list1.size.must_equal 3
    end

    it 'can determine empty list size' do
      @work.size.must_equal 0
    end

    it 'does not modify receiver' do
      @list1.size
      @list1.to_a.must_equal [@todo1, @todo2, @todo3]
      @list1.title.must_equal @title
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#<<' do
    it 'can add todo to empty list' do
      @work << @todo1.clone
      @work.to_a.must_equal [@todo1]
    end

    it 'can add todo to populated list' do
      feed_cats = Todo.new('Feed cats')
      @list1 << feed_cats.clone
      @list1.to_a.must_equal @todos1 + [feed_cats]
    end

    it 'raises type error when adding invalid item' do
      derived_todo = DerivedTodo.new @todo1.title
      proc { @list2.add derived_todo }.must_raise TypeError
      proc { @work << 'This is not a Todo item' }.must_raise TypeError
      proc { @list1 << nil }.must_raise TypeError
      proc { @list2 << 0 }.must_raise TypeError
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#add' do
    it 'can add todo to empty list' do
      @work.add @todo1.clone
      @work.to_a.must_equal [@todo1]
    end

    it 'can add todo to populated list' do
      feed_cats = Todo.new('Feed cats')
      @list1 << feed_cats.clone
      @list1.to_a.must_equal @todos1 + [feed_cats]
    end

    it 'raises type error when adding invalid item' do
      derived_todo = DerivedTodo.new @todo1.title
      proc { @list2.add derived_todo }.must_raise TypeError
      proc { @work.add 'This is not a Todo item' }.must_raise TypeError
      proc { @list1.add nil }.must_raise TypeError
      proc { @list2.add 0 }.must_raise TypeError
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#first' do
    it 'returns first todo item' do
      @list1.first.must_equal @todo1
    end

    it 'returns nil from empty list' do
      @work.first.must_be_nil
    end

    it 'does not modify receiver' do
      @list1.first
      @list1.to_a.must_equal [@todo1, @todo2, @todo3]
      @list1.title.must_equal @title
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#last' do
    it 'returns last todo item' do
      @list1.last.must_equal @todo3
    end

    it 'returns nil from empty list' do
      @work.last.must_be_nil
    end

    it 'does not modify receiver' do
      @list1.last
      @list1.to_a.must_equal [@todo1, @todo2, @todo3]
      @list1.title.must_equal @title
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#shift' do
    it 'removes and returns first item from populated list' do
      @list1.shift.must_equal @todo1
      @list1.size.must_equal 2
      @list1.first.must_equal @todo2
    end

    it 'removes and returns only item from single item list' do
      @work << @todo2.clone
      @work.shift.must_equal @todo2
      @work.size.must_equal 0
    end

    it 'returns nil from empty list' do
      @work.shift.must_be_nil
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#pop' do
    it 'removes and returns last item from populated list' do
      @list1.pop.must_equal @todo3
      @list1.size.must_equal 2
      @list1.last.must_equal @todo2
    end

    it 'removes returns only item from single item list' do
      @work << @todo2.clone
      @work.pop.must_equal @todo2
      @work.size.must_equal 0
    end

    it 'returns nil from empty list' do
      @work.pop.must_be_nil
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#each' do
    it 'processes todos in sequence' do
      constructed_list = TodoList.new(@list1.title)
      @list1.each { |todo| constructed_list << todo.clone }
      constructed_list.size.must_equal 3
      constructed_list.to_a.must_equal [@todo1, @todo2, @todo3]
    end

    it 'returns original list' do
      @list1.each { nil }.must_be_same_as @list1
    end

    it 'does not modify receiver' do
      @list1.each { nil }
      @list1.to_a.must_equal [@todo1, @todo2, @todo3]
      @list1.title.must_equal @title
    end

    it 'returns iterator if block omitted' do
      iterator = @list1.each
      iterator.must_be_kind_of Enumerator
      iterator.map(&:title).must_equal @todos1.map(&:title)
    end

    it 'works with empty list' do
      constructed_list = []
      @work.each { |todo| constructed_list << todo }
      constructed_list.must_be_empty
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#done?' do
    it 'returns false if no todos are marked done' do
      @list1.wont_be :done?
    end

    it 'does not modify receiver' do
      @list1.done?
      @list1.to_a.must_equal [@todo1, @todo2, @todo3]
      @list1.title.must_equal @title
    end

    it 'returns false if only some todos are done' do
      @list1.last.done!
      @list1.wont_be :done?
    end

    it 'returns true if all todos are done' do
      @list1.each(&:done!)
      @list1.must_be :done?
    end

    it 'returns true on empty list' do
      @work.must_be :done?
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#item_at' do
    it 'returns todo indexed by non-negative integer' do
      @list1.item_at(1).must_equal @todo2
    end

    it 'does not modify receiver' do
      @list1.item_at 1
      @list1.to_a.must_equal [@todo1, @todo2, @todo3]
      @list1.title.must_equal @title
    end

    it 'returns todo indexed by negative integer' do
      @list1.item_at(-2).must_equal @todo2
    end

    it 'raises index error if index out of range' do
      proc { @list1.item_at 3 }.must_raise IndexError
      proc { @list1.item_at(-4) }.must_raise IndexError
    end

    it 'raises index error on empty list' do
      proc { @work.item_at 0 }.must_raise IndexError
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#mark_done_at' do
    it 'marks todo indexed by non-negative integer' do
      @list1.mark_done_at 1
      @list1.to_a.must_equal [@todo1, @todo2done, @todo3]
    end

    it 'marks todo indexed by negative integer' do
      @list1.mark_done_at(-2)
      @list1.to_a.must_equal [@todo1, @todo2done, @todo3]
    end

    it 'does not change todo that is already done' do
      @list1.mark_done_at 1
      @list1.mark_done_at 1
      @list1.to_a.must_equal [@todo1, @todo2done, @todo3]
    end

    it 'raises index error if index out of range' do
      proc { @list1.mark_done_at 3 }.must_raise IndexError
      proc { @list1.mark_done_at(-4) }.must_raise IndexError
    end

    it 'raises index error on empty list' do
      proc { @work.mark_done_at 0 }.must_raise IndexError
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#mark_undone_at' do
    it 'marks todo indexed by non-negative integer' do
      @list1.done!
      @list1.mark_undone_at 0
      @list1.to_a.must_equal [@todo1, @todo2done, @todo3done]
    end

    it 'marks todo indexed by negative integer' do
      @list1.done!
      @list1.mark_undone_at(-1)
      @list1.to_a.must_equal [@todo1done, @todo2done, @todo3]
    end

    it 'does not change todo if already undone' do
      @list1.done!
      @list1.mark_undone_at 2
      @list1.mark_undone_at 2
      @list1.to_a.must_equal [@todo1done, @todo2done, @todo3]
    end

    it 'raises index error if index out of range' do
      proc { @list1.mark_undone_at 3 }.must_raise IndexError
      proc { @list1.mark_undone_at(-4) }.must_raise IndexError
    end

    it 'raises index error on empty list' do
      proc { @work.mark_undone_at 0 }.must_raise IndexError
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#done!' do
    it 'marks all todos as done' do
      @list1.done!
      @list1.to_a.must_equal [@todo1done, @todo2done, @todo3done]
    end

    it 'marks the entire list as done' do
      @list1.done!
      @list1.must_be :done?
    end

    it 'empty list is always done' do
      @work.done!
      @work.must_be :done?
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#mark_all_done' do
    it 'marks all todos as done' do
      @list1.mark_all_done
      @list1.to_a.must_equal [@todo1done, @todo2done, @todo3done]
    end

    it 'marks the entire list as done' do
      @list1.mark_all_done
      @list1.must_be :done?
    end

    it 'empty list is always done' do
      @work.mark_all_done
      @work.must_be :done?
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#mark_all_undone' do
    it 'marks all todos as undone' do
      @list1.mark_all_done
      @list1.mark_all_undone
      @list1.to_a.must_equal [@todo1, @todo2, @todo3]
    end

    it 'marks the entire list as undone' do
      @list1.mark_all_done
      @list1.mark_all_undone
      @list1.wont_be :done?
    end

    it 'empty list is always done' do
      @work.mark_all_done
      @work.mark_all_undone
      @work.must_be :done?
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#undone!' do
    it 'marks all todos as undone' do
      @list1.done!
      @list1.undone!
      @list1.to_a.must_equal [@todo1, @todo2, @todo3]
    end

    it 'marks the entire list as undone' do
      @list1.done!
      @list1.undone!
      @list1.wont_be :done?
    end

    it 'empty list is always done' do
      @work.done!
      @work.undone!
      @work.must_be :done?
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#remove_at' do
    it 'removes todo indexed by non-negative integer' do
      @list1.remove_at 1
      @list1.size.must_equal 2
      @list1.to_a.must_equal [@todo1, @todo3]
    end

    it 'removes todo indexed by negative integer' do
      @list1.remove_at(-1)
      @list1.size.must_equal 2
      @list1.to_a.must_equal [@todo1, @todo2]
    end

    it 'removing same index twice in row removes two todos' do
      @list1.remove_at 1
      @list1.remove_at 1
      @list1.size.must_equal 1
      @list1.to_a.must_equal [@todo1]
    end

    it 'raises index error if index out of range' do
      proc { @list1.remove_at 3 }.must_raise IndexError
      proc { @list1.remove_at(-4) }.must_raise IndexError
    end

    it 'raises index error on empty list' do
      proc { @work.remove_at 2 }.must_raise IndexError
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#to_s' do
    it 'shows all items in undone state' do
      output = <<~OUTPUT.chomp
        ---- #{@title} ----
        [ ] Buy milk
        [ ] Clean room
        [ ] Go to gym
      OUTPUT

      @list1.to_s.must_equal output
    end

    it 'does not modify receiver' do
      @list1.to_s
      @list1.to_a.must_equal [@todo1, @todo2, @todo3]
      @list1.title.must_equal @title
    end

    it 'shows some items in done state, some in undone state' do
      output = <<~OUTPUT.chomp
        ---- #{@title} ----
        [ ] Buy milk
        [X] Clean room
        [ ] Go to gym
      OUTPUT

      @list1.mark_done_at 1
      @list1.to_s.must_equal output
    end

    it 'shows all items in done state' do
      output = <<~OUTPUT.chomp
        ---- #{@title} ----
        [X] Buy milk
        [X] Clean room
        [X] Go to gym
      OUTPUT

      @list1.done!
      @list1.to_s.must_equal output
    end

    it 'shows empty list' do
      @work.to_s.must_equal "---- My Todo List ----\n"
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#select' do
    it 'finds specified todo with block' do
      result = @list1.select { |todo| todo.title == @todo2.title }.to_a
      result.must_equal [@todo2]
    end

    it 'finds specified todo with method' do
      @list1.mark_done_at 1
      @list1.select(&:done?).to_a.must_equal [@todo2done]
    end

    it 'finds multiple items if dups present' do
      @list1 << @todo1
      result = @list1.select { |todo| todo.title == @todo1.title }.to_a
      result.must_equal [@todo1, @todo1]
    end

    it 'returns new todo list' do
      result = @list1.select { true }
      result.must_be_kind_of TodoList
      result.wont_be_same_as @list1
    end

    it 'does not modify receiver' do
      @list1.select { false }
      @list1.to_a.must_equal [@todo1, @todo2, @todo3]
      @list1.title.must_equal @title
    end

    it 'returns empty list if no matches' do
      @list1.select { |todo| todo.title == 'x' }.to_a.must_be_empty
    end

    it 'returns iterator if block omitted' do
      expected = [Todo.new('Clean room'), Todo.new('Go to gym')]
      iterator = @list1.select
      iterator.must_be_kind_of Enumerator
      result = iterator.each { |todo| todo.title.include?('o') }.to_a
      result.must_equal expected
    end

    it 'returns empty list if empty todo list' do
      @work.select { true }.to_a.must_be_empty
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#find_by_title' do
    it 'finds item' do
      @list1.find_by_title(@todo2.title).must_equal @todo2
    end

    it 'does not modify receiver' do
      @list1.find_by_title(@todo2.title)
      @list1.to_a.must_equal [@todo1, @todo2, @todo3]
      @list1.title.must_equal @title
    end

    it 'finds first item when dups present' do
      @list1 << @todo1.clone
      result = @list1.find_by_title @todo1.title
      result.must_be_same_as @list1.first
      result.wont_be_same_as @list1.last
    end

    it 'returns nil if item not present' do
      @list1.find_by_title('x').must_be_nil
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#mark_done' do
    it 'marks matched item as done' do
      @list1.mark_done @todo2.title
      @list1.to_a.must_equal [@todo1, @todo2done, @todo3]
    end

    it 'marks only first item as done' do
      @list1 << Todo.new(@todo1.title)
      @list1.mark_done @todo1.title
      @list1.to_a.must_equal [@todo1done, @todo2, @todo3, @todo1]
    end

    it 'marks nothing if no items are matched' do
      @list1.mark_done 'x'
      @list1.to_a.must_equal [@todo1, @todo2, @todo3]
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#all_done' do
    it 'returns empty list if nothing done' do
      @list1.all_done.to_a.must_be_empty
    end

    it 'returns empty list if empty list' do
      @work.all_done.to_a.must_be_empty
    end

    it 'returns done items' do
      @list1.mark_done_at 0
      @list1.mark_done_at 2
      @list1.all_done.to_a.must_equal [@todo1done, @todo3done]
    end

    it 'does not modify receiver' do
      @list1.mark_done_at 0
      @list1.mark_done_at 2
      @list1.all_done
      @list1.to_a.must_equal [@todo1done, @todo2, @todo3done]
      @list1.title.must_equal @title
    end
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  describe '#all_not_done' do
    it 'returns empty list if everything is done' do
      @list1.done!
      @list1.all_not_done.to_a.must_be_empty
    end

    it 'returns empty list if empty list' do
      @work.all_not_done.to_a.must_be_empty
    end

    it 'returns undone items' do
      @list1.mark_done_at 0
      @list1.mark_done_at 2
      @list1.all_not_done.to_a.must_equal [@todo2]
    end

    it 'does not modify receiver' do
      @list1.mark_done_at 0
      @list1.mark_done_at 2
      @list1.all_not_done
      @list1.to_a.must_equal [@todo1done, @todo2, @todo3done]
      @list1.title.must_equal @title
    end
  end
end
