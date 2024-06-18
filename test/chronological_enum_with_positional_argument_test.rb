# frozen_string_literal: true

require 'test_helper'

ActiveRecord::Schema.define do
  create_table :dummy_class_with_positional_arguments, force: true do |t|
    t.integer :status
  end
end

class DummyClassWithPositionalArgument < ActiveRecord::Base
  enum :status, { created: 0, processing: 1, finished: 2 }, _chronological: true
end

class ChronologicalEnumWithPositionalArgument < Minitest::Test
  def test_scopes_with_positional_argument
    DummyClassWithPositionalArgument.create(status: 'created')
    DummyClassWithPositionalArgument.create(status: 'processing')
    DummyClassWithPositionalArgument.create(status: 'finished')

    assert_equal 1, DummyClassWithPositionalArgument.created.count
    assert_equal 1, DummyClassWithPositionalArgument.processing.count
    assert_equal 1, DummyClassWithPositionalArgument.finished.count

    assert_equal 0, DummyClassWithPositionalArgument.before_created.count
    assert_equal 1, DummyClassWithPositionalArgument.before_or_created.count
    assert_equal 2, DummyClassWithPositionalArgument.after_created.count
    assert_equal 3, DummyClassWithPositionalArgument.after_or_created.count

    assert_equal 1, DummyClassWithPositionalArgument.before_processing.count
    assert_equal 2, DummyClassWithPositionalArgument.before_or_processing.count
    assert_equal 1, DummyClassWithPositionalArgument.after_processing.count
    assert_equal 2, DummyClassWithPositionalArgument.after_or_processing.count

    assert_equal 2, DummyClassWithPositionalArgument.before_finished.count
    assert_equal 3, DummyClassWithPositionalArgument.before_or_finished.count
    assert_equal 0, DummyClassWithPositionalArgument.after_finished.count
    assert_equal 1, DummyClassWithPositionalArgument.after_or_finished.count
  end
end
