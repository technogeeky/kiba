require_relative 'helper'

require_relative 'support/test_rename_field_transform'
require_relative 'support/test_enumerable_source'

class DummyClass
end

class TestParser < Kiba::Test
  def test_source_definition
    control = Kiba.parse do
      source DummyClass, 'has', 'args'
    end

    assert_equal DummyClass, control.sources[0][:klass]
    assert_equal %w(has args), control.sources[0][:args]
  end

  def test_block_transform_definition
    control = Kiba.parse do
      transform { |row| row }
    end

    assert_instance_of Proc, control.transforms[0][:block]
  end

  def test_class_transform_definition
    control = Kiba.parse do
      transform TestRenameFieldTransform, :last_name, :name
    end

    assert_equal TestRenameFieldTransform, control.transforms[0][:klass]
    assert_equal [:last_name, :name], control.transforms[0][:args]
  end

  def test_destination_definition
    control = Kiba.parse do
      destination DummyClass, 'has', 'args'
    end

    assert_equal DummyClass, control.destinations[0][:klass]
    assert_equal %w(has args), control.destinations[0][:args]
  end

  def test_block_post_process_definition
    control = Kiba.parse do
      post_process {}
    end

    assert_instance_of Proc, control.post_processes[0][:block]
  end
  
  def test_block_pre_process_definition
    control = Kiba.parse do
      pre_process {}
    end

    assert_instance_of Proc, control.pre_processes[0][:block]
  end

  def test_source_as_string_parsing
    control = Kiba.parse <<RUBY
      source DummyClass, 'from', 'file'
RUBY

    assert_equal 1, control.sources.size
    assert_equal DummyClass, control.sources[0][:klass]
    assert_equal %w(from file), control.sources[0][:args]
  end

  def test_source_as_file_doing_require
    IO.write 'test/tmp/etl-common.rb', <<RUBY
      def common_source_declaration
        source DummyClass, 'from', 'common'
      end
RUBY
    IO.write 'test/tmp/etl-main.rb', <<RUBY
      require './test/tmp/etl-common.rb'

      source DummyClass, 'from', 'main'
      common_source_declaration
RUBY
    control = Kiba.parse IO.read('test/tmp/etl-main.rb')

    assert_equal 2, control.sources.size

    assert_equal %w(from main), control.sources[0][:args]
    assert_equal %w(from common), control.sources[1][:args]

  ensure
    remove_files('test/tmp/etl-common.rb', 'test/tmp/etl-main.rb')
  end

  def test_stack_read_and_write_at_parse_time
    block = Proc.new do
      # the stack can be read from
      source TestEnumerableSource, stack[:some_input]
      # and written to at parse time
      stack[:some_output] = 'hello'

      pre_process do
        # it can also be written at run time
        stack[:row_count] = 0
      end

      transform do |row|
        stack[:row_count] += 1
        row
      end
    end

    stack = { some_input: (1..4) }
    control = Kiba.parse(nil, nil, stack, &block)
    # job declaration must have been impacted
    assert_equal (1..4), control.sources[0][:args].first
    # after parse we can check what is in there
    assert_equal 'hello', stack[:some_output]

    assert_equal nil, stack[:row_count]
    Kiba.run(control)

    assert_equal 4, stack[:row_count]
  end
end
