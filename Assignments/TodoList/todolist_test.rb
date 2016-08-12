require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

# rubocop:disable MethodLength

require_relative 'todo'
require_relative 'todolist'

#------------------------------------------------------------------------------
# This helps me avoid use of assert and refute when not intended.

module MiniTestExtensions
  def assert_true(test) # NOTE: lack of message param is intentional
    assert !(!test)
  end

  def assert_false(test) # NOTE: lack of message param is intentional
    refute !(!test)
  end
end

#------------------------------------------------------------------------------

class TodoTest < MiniTest::Test
  include MiniTestExtensions

  make_my_diffs_pretty!

  class DerivedTodo < Todo; end

  def setup
    @todo1 = Todo.new 'Item title', 'Item description'
    @todo2 = Todo.new 'Item title2'
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  def test_initialization
    assert_equal 'Item title', @todo1.title
    assert_equal 'Item description', @todo1.description
    assert_false @todo1.done
  end

  def test_initialization_with_default_description
    assert_equal 'Item title2', @todo2.title
    assert_equal '', @todo2.description
    assert_false @todo2.done
  end

  def test_can_change_title
    @todo1.title = 'Abc'
    assert_equal 'Abc', @todo1.title
  end

  def test_can_change_description
    @todo1.description = 'Abc'
    assert_equal 'Abc', @todo1.description
  end

  def test_can_change_done_with_accessor
    @todo1.done = true
    assert_true @todo1.done
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  def test_can_mark_done
    @todo1.done!
    assert_true @todo1.done
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  def test_can_mark_undone
    @todo2.done!
    @todo2.undone!
    assert_false @todo2.done
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  def test_query_done_state
    assert_false @todo1.done?
    @todo1.done!
    assert_true @todo1.done?
    @todo1.undone!
    assert_false @todo1.done
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  def test_can_convert_to_string_when_not_done
    assert_equal '[ ] Item title', @todo1.to_s
    assert_equal '[ ] Item title2', @todo2.to_s
  end

  def test_can_convert_to_string_when_done
    @todo1.done!
    @todo2.done!
    assert_equal '[X] Item title', @todo1.to_s
    assert_equal '[X] Item title2', @todo2.to_s
  end

  def test_make_sure_string_conversion_works_when_using_undone!
    @todo1.done!
    @todo2.done!
    @todo1.undone!
    @todo2.undone!
    assert_equal '[ ] Item title', @todo1.to_s
    assert_equal '[ ] Item title2', @todo2.to_s
  end

  # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  # Monkey-patched == method

  def test_is_true_when_all_attributes_are_the_same
    assert_equal @todo1, Todo.new(@todo1.title, @todo1.description)
  end

  def test_is_false_if_the_title_is_different
    refute_equal @todo1, Todo.new(@todo1.title + 'x', @todo1.description)
  end

  def test_is_false_if_the_description_is_different
    refute_equal @todo1, Todo.new(@todo1.title, @todo1.description + 'x')
  end

  def test_is_false_if_the_done_state_is_different
    new_todo = Todo.new(@todo1.title, @todo1.description)
    new_todo.done!
    refute_equal @todo1, new_todo
  end

  def test_is_false_if_the_other_object_is_not_a_todo_object
    new_todo = DerivedTodo.new(@todo1.title, @todo1.description)
    refute_equal @todo1, new_todo
    refute_equal 3, new_todo
    refute_equal 'Item title', new_todo
  end
end

#------------------------------------------------------------------------------

class TodoListTest < MiniTest::Test
  include MiniTestExtensions

  make_my_diffs_pretty!

  class DerivedTodo < Todo; end

  def setup
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
end

#------------------------------------------------------------------------------

class TestTitle < TodoListTest
  def test_that_title_is_set_correctly
    assert_equal @title, @list1.title
  end

  def test_can_change_title
    @list1.title = 'Abc Def'
    assert_equal 'Abc Def', @list1.title
  end

  def test_does_not_modify_the_todo_list
    @list1.last
    assert_equal [@todo1, @todo2, @todo3], @list1.to_a
  end
end

#------------------------------------------------------------------------------

class TestToA < TodoListTest
  def test_can_convert_populated_list_to_array
    assert_equal @todos1, @list1.to_a
  end

  def test_can_convert_empty_list_to_array
    assert_empty @work.to_a
  end
end

#------------------------------------------------------------------------------

class TestSize < TodoListTest
  def test_can_determine_populated_list_size
    assert_equal 3, @list1.size
  end

  def test_can_determine_empty_list_size
    assert_equal 0, @work.size
  end

  def test_does_not_modify_receiver
    @list1.size
    assert_equal [@todo1, @todo2, @todo3], @list1.to_a
    assert_equal @title, @list1.title
  end
end

#------------------------------------------------------------------------------

class TestShovelOp < TodoListTest
  def test_can_add_todo_to_empty_list
    @work << @todo1.clone
    assert_equal [@todo1], @work.to_a
  end

  def test_can_add_todo_to_populated_list
    feed_cats = Todo.new('Feed cats')
    @list1 << feed_cats.clone
    assert_equal @todos1 + [feed_cats], @list1.to_a
  end

  def test_raises_type_error_when_adding_invalid_item
    derived_todo = DerivedTodo.new @todo1.title
    assert_raises(TypeError) { @list2.add derived_todo }
    assert_raises(TypeError) { @work << 'This is not a Todo item' }
    assert_raises(TypeError) { @list1 << nil }
    assert_raises(TypeError) { @list2 << 0 }
  end
end

#------------------------------------------------------------------------------

class TestAdd < TodoListTest
  def test_can_add_todo_to_empty_list
    @work.add @todo1.clone
    assert_equal [@todo1], @work.to_a
  end

  def test_can_add_todo_to_populated_list
    feed_cats = Todo.new('Feed cats')
    @list1 << feed_cats.clone
    assert_equal @todos1 + [feed_cats], @list1.to_a
  end

  def test_raises_type_error_when_adding_invalid_item
    derived_todo = DerivedTodo.new @todo1.title
    assert_raises(TypeError) { @list2.add derived_todo }
    assert_raises(TypeError) { @work.add 'This is not a Todo item' }
    assert_raises(TypeError) { @list1.add nil }
    assert_raises(TypeError) { @list2.add 0 }
  end
end

#------------------------------------------------------------------------------

class TestFirst < TodoListTest
  def test_returns_first_todo_item
    assert_equal @todo1, @list1.first
  end

  def test_returns_nil_from_empty_list
    assert_nil @work.first
  end

  def test_does_not_modify_receiver
    @list1.first
    assert_equal [@todo1, @todo2, @todo3], @list1.to_a
    assert_equal @title, @list1.title
  end
end

#------------------------------------------------------------------------------

class TestLast < TodoListTest
  def test_returns_last_todo_item
    assert_equal @todo3, @list1.last
  end

  def test_returns_nil_from_empty_list
    assert_nil @work.last
  end

  def test_does_not_modify_receiver
    @list1.last
    assert_equal [@todo1, @todo2, @todo3], @list1.to_a
    assert_equal @title, @list1.title
  end
end

#------------------------------------------------------------------------------

class TestShift < TodoListTest
  def test_returns_first_item_from_populated_list
    assert_equal @todo1, @list1.shift
    assert_equal 2, @list1.size
    assert_equal @todo2, @list1.first
  end

  def test_returns_first_item_from_single_item_list
    @work << @todo2.clone
    assert_equal @todo2, @work.shift
    assert_equal 0, @work.size
  end

  def test_returns_nil_from_empty_list
    assert_nil @work.shift
  end
end

#------------------------------------------------------------------------------

class TestPop < TodoListTest
  def test_returns_last_item_from_populated_lsit
    assert_equal @todo3, @list1.pop
    assert_equal 2, @list1.size
    assert_equal @todo2, @list1.last
  end

  def test_returns_last_item_from_single_item_list
    @work << @todo2.clone
    assert_equal @todo2, @work.pop
    assert_equal 0, @work.size
  end

  def test_returns_nil_from_empty_list
    assert_nil @work.pop
  end
end

#------------------------------------------------------------------------------

class TestEach < TodoListTest
  def test_todos_processed_in_sequence
    constructed_list = TodoList.new(@list1.title)
    @list1.each { |todo| constructed_list << todo.clone }
    assert_equal 3, constructed_list.size
    assert_equal [@todo1, @todo2, @todo3], constructed_list.to_a
  end

  def test_returns_original_list
    assert_same @list1, @list1.each { nil }
  end

  def test_does_not_modify_receiver
    @list1.each { nil }
    assert_equal [@todo1, @todo2, @todo3], @list1.to_a
    assert_equal @title, @list1.title
  end

  def test_returns_iterator_if_block_omitted
    iterator = @list1.each
    assert_kind_of Enumerator, iterator
    assert_equal @todos1.map(&:title), iterator.map(&:title)
  end

  def test_works_with_empty_list
    constructed_list = []
    @work.each { |todo| constructed_list << todo }
    assert_empty constructed_list
  end
end

#------------------------------------------------------------------------------

class TestDoneQuery < TodoListTest
  def test_returns_false_if_no_todos_are_done
    assert_false @list1.done?
  end

  def test_does_not_modify_receiver
    @list1.done?
    assert_equal [@todo1, @todo2, @todo3], @list1.to_a
    assert_equal @title, @list1.title
  end

  def test_returns_false_if_only_some_todos_are_done
    @list1.last.done!
    assert_false @list1.done?
  end

  def test_returns_true_if_all_todos_are_done
    @list1.each(&:done!)
    assert_true @list1.done?
  end

  def test_returns_true_on_empty_list
    assert_true @work.done?
  end
end

#------------------------------------------------------------------------------

class TestItemAt < TodoListTest
  def test_returns_todo_indexed_by_non_negative_integer
    assert_equal @todo2, @list1.item_at(1)
  end

  def test_does_not_modify_receiver
    @list1.item_at 1
    assert_equal [@todo1, @todo2, @todo3], @list1.to_a
    assert_equal @title, @list1.title
  end

  def test_returns_todo_indexed_by_negative_integer
    assert_equal @todo2, @list1.item_at(-2)
  end

  def test_raises_index_error_if_index_out_of_range
    assert_raises(IndexError) { @list1.item_at 3 }
    assert_raises(IndexError) { @list1.item_at(-4) }
  end

  def test_raises_index_error_on_empty_list
    assert_raises(IndexError) { @work.item_at 0 }
  end
end

#------------------------------------------------------------------------------

class TestMarkDoneAt < TodoListTest
  def test_marks_todo_indexed_by_non_negative_integer
    @list1.mark_done_at 1
    assert_equal [@todo1, @todo2done, @todo3], @list1.to_a
  end

  def test_marks_todo_indexed_by_negative_integer
    @list1.mark_done_at(-2)
    assert_equal [@todo1, @todo2done, @todo3], @list1.to_a
  end

  def test_does_not_change_todo_that_is_already_done
    @list1.mark_done_at 1
    @list1.mark_done_at 1
    assert_equal [@todo1, @todo2done, @todo3], @list1.to_a
  end

  def test_raises_index_error_if_index_out_of_range
    assert_raises(IndexError) { @list1.mark_done_at 3 }
    assert_raises(IndexError) { @list1.mark_done_at(-4) }
  end

  def test_raises_index_error_on_empty_list
    assert_raises(IndexError) { @work.mark_done_at 0 }
  end
end

#------------------------------------------------------------------------------

class TestMarkUndoneAt < TodoListTest
  def test_marks_todo_indexed_by_non_negative_integer
    @list1.done!
    @list1.mark_undone_at 0
    assert_equal [@todo1, @todo2done, @todo3done], @list1.to_a
  end

  def test_marks_todo_indexed_by_negative_integer
    @list1.done!
    @list1.mark_undone_at(-1)
    assert_equal [@todo1done, @todo2done, @todo3], @list1.to_a
  end

  def test_does_not_change_todo_if_already_undone
    @list1.done!
    @list1.mark_undone_at 2
    @list1.mark_undone_at 2
    assert_equal [@todo1done, @todo2done, @todo3], @list1.to_a
  end

  def test_raises_index_error_if_index_out_of_range
    assert_raises(IndexError) { @list1.mark_undone_at 3 }
    assert_raises(IndexError) { @list1.mark_undone_at(-4) }
  end

  def test_raises_index_error_on_empty_list
    assert_raises(IndexError) { @work.mark_undone_at 0 }
  end
end

#------------------------------------------------------------------------------

class TestDoneBang < TodoListTest
  def test_marks_all_todos_as_done
    @list1.done!
    assert_equal [@todo1done, @todo2done, @todo3done], @list1.to_a
  end

  def test_marks_the_entire_list_as_done
    @list1.done!
    assert_true @list1.done?
  end

  def test_empty_list_is_always_done
    @work.done!
    assert_true @work.done?
  end
end

#------------------------------------------------------------------------------

class TestMarkAllDone < TodoListTest
  def test_marks_all_todos_as_done
    @list1.mark_all_done
    assert_equal [@todo1done, @todo2done, @todo3done], @list1.to_a
  end

  def test_marks_the_entire_list_as_done
    @list1.mark_all_done
    assert_true @list1.done?
  end

  def test_empty_list_is_always_done
    @work.mark_all_done
    assert_true @work.done?
  end
end

#------------------------------------------------------------------------------

class TestMarkAllUndone < TodoListTest
  def test_marks_all_todos_as_undone
    @list1.mark_all_done
    @list1.mark_all_undone
    assert_equal [@todo1, @todo2, @todo3], @list1.to_a
  end

  def test_marks_the_entire_list_as_undone
    @list1.mark_all_done
    @list1.mark_all_undone
    assert_false @list1.done?
  end

  def test_empty_list_is_always_done
    @work.mark_all_done
    @work.mark_all_undone
    assert_true @work.done?
  end
end

#------------------------------------------------------------------------------

class TestUndoneBang < TodoListTest
  def test_marks_all_todos_as_undone
    @list1.done!
    @list1.undone!
    assert_equal [@todo1, @todo2, @todo3], @list1.to_a
  end

  def test_marks_the_entire_list_as_undone
    @list1.done!
    @list1.undone!
    assert_false @list1.done?
  end

  def test_empty_list_is_always_done
    @work.done!
    @work.undone!
    assert_true @work.done?
  end
end

#------------------------------------------------------------------------------

class TestRemoveAt < TodoListTest
  def test_removes_todo_indexed_by_non_negative_integer
    @list1.remove_at 1
    assert_equal 2, @list1.size
    assert_equal [@todo1, @todo3], @list1.to_a
  end

  def test_removes_todo_indexed_by_negative_integer
    @list1.remove_at(-1)
    assert_equal 2, @list1.size
    assert_equal [@todo1, @todo2], @list1.to_a
  end

  def test_removing_same_index_twice_in_row_removes_two_todos
    @list1.remove_at 1
    @list1.remove_at 1
    assert_equal 1, @list1.size
    assert_equal [@todo1], @list1.to_a
  end

  def test_raises_index_error_if_index_out_of_range
    assert_raises(IndexError) { @list1.remove_at 3 }
    assert_raises(IndexError) { @list1.remove_at(-4) }
  end

  def test_raises_index_error_on_empty_list
    assert_raises(IndexError) { @work.remove_at 2 }
  end
end

#------------------------------------------------------------------------------

class TestToS < TodoListTest
  def test_shows_all_items_undone
    output = <<~OUTPUT.chomp
      ---- #{@title} ----
      [ ] Buy milk
      [ ] Clean room
      [ ] Go to gym
    OUTPUT

    assert_equal output, @list1.to_s
  end

  def test_does_not_modify_receiver
    @list1.to_s
    assert_equal [@todo1, @todo2, @todo3], @list1.to_a
    assert_equal @title, @list1.title
  end

  def test_shows_some_items_done
    output = <<~OUTPUT.chomp
      ---- #{@title} ----
      [ ] Buy milk
      [X] Clean room
      [ ] Go to gym
    OUTPUT

    @list1.mark_done_at 1
    assert_equal output, @list1.to_s
  end

  def test_shows_all_items_done
    output = <<~OUTPUT.chomp
      ---- #{@title} ----
      [X] Buy milk
      [X] Clean room
      [X] Go to gym
    OUTPUT

    @list1.done!
    assert_equal output, @list1.to_s
  end

  def test_shows_empty_list
    assert_equal "---- My Todo List ----\n", @work.to_s
  end
end

#------------------------------------------------------------------------------

class TestSelect < TodoListTest
  def test_finds_specified_todo_with_block
    result = @list1.select { |todo| todo.title == @todo2.title }.to_a
    assert_equal [@todo2], result
  end

  def test_finds_specified_todo_with_method
    @list1.mark_done_at 1
    assert_equal [@todo2done], @list1.select(&:done?).to_a
  end

  def test_finds_multiple_items_if_dups_present
    @list1 << @todo1
    result = @list1.select { |todo| todo.title == @todo1.title }.to_a
    assert_equal [@todo1, @todo1], result
  end

  def test_returns_new_todo_list
    result = @list1.select { true }
    assert_kind_of TodoList, result
    refute_same @list1, result
  end

  def test_does_not_modify_receiver
    @list1.select { false }
    assert_equal [@todo1, @todo2, @todo3], @list1.to_a
    assert_equal @title, @list1.title
  end

  def test_returns_empty_list_if_no_matches
    assert_empty @list1.select { |todo| todo.title == 'x' }.to_a
  end

  def test_returns_iterator_if_block_omitted
    expected = [Todo.new('Clean room'), Todo.new('Go to gym')]
    iterator = @list1.select
    assert_kind_of Enumerator, iterator
    result = iterator.each { |todo| todo.title.include?('o') }.to_a
    assert_equal expected, result
  end

  def test_returns_empty_list_if_empty_todo_list
    assert_empty @work.select { true }.to_a
  end
end

#------------------------------------------------------------------------------

class TestFindByTitle < TodoListTest
  def test_finds_item
    assert_equal @todo2, @list1.find_by_title(@todo2.title)
  end

  def test_does_not_modify_receiver
    @list1.find_by_title(@todo2.title)
    assert_equal [@todo1, @todo2, @todo3], @list1.to_a
    assert_equal @title, @list1.title
  end

  def test_finds_first_item_when_dups_present
    @list1 << @todo1.clone
    result = @list1.find_by_title @todo1.title
    assert_same @list1.first, result
    refute_same @list1.last, result
  end

  def test_returns_nil_if_item_not_present
    assert_nil @list1.find_by_title('x')
  end
end

#------------------------------------------------------------------------------

class TestMarkDone < TodoListTest
  def test_marks_matched_item_as_done
    @list1.mark_done @todo2.title
    assert_equal [@todo1, @todo2done, @todo3], @list1.to_a
  end

  def test_marks_only_first_item_as_done
    @list1 << Todo.new(@todo1.title)
    @list1.mark_done @todo1.title
    assert_equal [@todo1done, @todo2, @todo3, @todo1], @list1.to_a
  end

  def test_marks_nothing_if_no_items_are_matched
    @list1.mark_done 'x'
    assert_equal [@todo1, @todo2, @todo3], @list1.to_a
  end
end

#------------------------------------------------------------------------------

class TestAllDone < TodoListTest
  def test_returns_empty_list_if_nothing_done
    assert_empty @list1.all_done.to_a
  end

  def test_returns_empty_list_if_empty_list
    assert_empty @work.all_done.to_a
  end

  def test_returns_done_items
    @list1.mark_done_at 0
    @list1.mark_done_at 2
    assert_equal [@todo1done, @todo3done], @list1.all_done.to_a
  end

  def test_does_not_modify_receiver
    @list1.mark_done_at 0
    @list1.mark_done_at 2
    @list1.all_done
    assert_equal [@todo1done, @todo2, @todo3done], @list1.to_a
    assert_equal @title, @list1.title
  end
end

#------------------------------------------------------------------------------

class TestAllNotDone < TodoListTest
  def test_returns_empty_list_if_everything_is_done
    @list1.done!
    assert_empty @list1.all_not_done.to_a
  end

  def test_returns_empty_list_if_empty_list
    assert_empty @work.all_not_done.to_a
  end

  def test_returns_undone_items
    @list1.mark_done_at 0
    @list1.mark_done_at 2
    assert_equal [@todo2], @list1.all_not_done.to_a
  end

  def test_does_not_modify_receiver
    @list1.mark_done_at 0
    @list1.mark_done_at 2
    @list1.all_not_done
    assert_equal [@todo1done, @todo2, @todo3done], @list1.to_a
    assert_equal @title, @list1.title
  end
end
