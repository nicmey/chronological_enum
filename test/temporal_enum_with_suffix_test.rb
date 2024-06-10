# frozen_string_literal: true

require 'test_helper'

class TemporalEnumWithPrefixTest < Minitest::Test
  ActiveRecord::Schema.define do
    create_table :dummy_classes, force: true do |t|
      t.integer :status
    end
  end

  class DummyClass < ActiveRecord::Base
    extend TemporalEnum

    enum status: { created: 0, processing: 1, finished: 2 }, _suffix: true
    temporal_enum(:status)
  end

  def test_scopes_with_suffix_are_correct
    DummyClass.create(status: 'created')
    DummyClass.create(status: 'processing')
    DummyClass.create(status: 'finished')

    assert_equal 1, DummyClass.created_status.count
    assert_equal 1, DummyClass.processing_status.count
    assert_equal 1, DummyClass.finished_status.count

    assert_equal 0, DummyClass.before_created_status.count
    assert_equal 1, DummyClass.before_or_created_status.count
    assert_equal 2, DummyClass.after_created_status.count
    assert_equal 3, DummyClass.after_or_created_status.count

    assert_equal 1, DummyClass.before_processing_status.count
    assert_equal 2, DummyClass.before_or_processing_status.count
    assert_equal 1, DummyClass.after_processing_status.count
    assert_equal 2, DummyClass.after_or_processing_status.count

    assert_equal 2, DummyClass.before_finished_status.count
    assert_equal 3, DummyClass.before_or_finished_status.count
    assert_equal 0, DummyClass.after_finished_status.count
    assert_equal 1, DummyClass.after_or_finished_status.count
  end
end
