# frozen_string_literal: true

require 'test_helper'

class TemporalEnumWithNamedPrefixTest < Minitest::Test
  ActiveRecord::Schema.define do
    create_table :new_dummy_classes, force: true do |t|
      t.integer :status
    end
  end

  class NewDummyClass < ActiveRecord::Base
    extend TemporalEnum

    enum status: { created: 0, processing: 1, finished: 2 }, _prefix: 'prefix'
    temporal_enum(:status)
  end

  def test_with_named_prefix_scopes_are_correct
    NewDummyClass.create(status: 'created')
    NewDummyClass.create(status: 'processing')
    NewDummyClass.create(status: 'finished')

    assert_equal 1, NewDummyClass.prefix_created.count
    assert_equal 1, NewDummyClass.prefix_processing.count
    assert_equal 1, NewDummyClass.prefix_finished.count

    assert_equal 0, NewDummyClass.before_prefix_created.count
    assert_equal 1, NewDummyClass.before_or_prefix_created.count
    assert_equal 2, NewDummyClass.after_prefix_created.count
    assert_equal 3, NewDummyClass.after_or_prefix_created.count

    assert_equal 1, NewDummyClass.before_prefix_processing.count
    assert_equal 2, NewDummyClass.before_or_prefix_processing.count
    assert_equal 1, NewDummyClass.after_prefix_processing.count
    assert_equal 2, NewDummyClass.after_or_prefix_processing.count

    assert_equal 2, NewDummyClass.before_prefix_finished.count
    assert_equal 3, NewDummyClass.before_or_prefix_finished.count
    assert_equal 0, NewDummyClass.after_prefix_finished.count
    assert_equal 1, NewDummyClass.after_or_prefix_finished.count
  end
end
