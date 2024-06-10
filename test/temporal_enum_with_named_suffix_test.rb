# frozen_string_literal: true

require 'test_helper'

class TemporalEnumWithNamedSuffixTest < Minitest::Test
  ActiveRecord::Schema.define do
    create_table :new_new_dummy_classes, force: true do |t|
      t.integer :status
    end
  end

  class NewNewDummyClass < ActiveRecord::Base
    extend TemporalEnum

    enum status: { created: 0, processing: 1, finished: 2 }, _suffix: 'suffix'
    temporal_enum(:status)
  end

  def test_with_named_prefix_scopes_are_correct
    NewNewDummyClass.create(status: 'created')
    NewNewDummyClass.create(status: 'processing')
    NewNewDummyClass.create(status: 'finished')

    assert_equal 1, NewNewDummyClass.created_suffix.count
    assert_equal 1, NewNewDummyClass.processing_suffix.count
    assert_equal 1, NewNewDummyClass.finished_suffix.count

    assert_equal 0, NewNewDummyClass.before_created_suffix.count
    assert_equal 1, NewNewDummyClass.before_or_created_suffix.count
    assert_equal 2, NewNewDummyClass.after_created_suffix.count
    assert_equal 3, NewNewDummyClass.after_or_created_suffix.count

    assert_equal 1, NewNewDummyClass.before_processing_suffix.count
    assert_equal 2, NewNewDummyClass.before_or_processing_suffix.count
    assert_equal 1, NewNewDummyClass.after_processing_suffix.count
    assert_equal 2, NewNewDummyClass.after_or_processing_suffix.count

    assert_equal 2, NewNewDummyClass.before_finished_suffix.count
    assert_equal 3, NewNewDummyClass.before_or_finished_suffix.count
    assert_equal 0, NewNewDummyClass.after_finished_suffix.count
    assert_equal 1, NewNewDummyClass.after_or_finished_suffix.count
  end
end
