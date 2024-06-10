# frozen_string_literal: true

require 'test_helper'

class TemporalEnumWithPrefixTest < Minitest::Test
  ActiveRecord::Schema.define do
    create_table :test_classes, force: true do |t|
      t.integer :status
    end
  end

  class TestClass < ActiveRecord::Base
    extend TemporalEnum

    enum status: { created: 0, processing: 1, finished: 2 }, _prefix: true
    temporal_enum(:status)
  end

  def test_scopes_with_prefix_are_correct
    TestClass.create(status: 'created')
    TestClass.create(status: 'processing')
    TestClass.create(status: 'finished')

    assert_equal 1, TestClass.status_created.count
    assert_equal 1, TestClass.status_processing.count
    assert_equal 1, TestClass.status_finished.count

    assert_equal 0, TestClass.before_status_created.count
    assert_equal 1, TestClass.before_or_status_created.count
    assert_equal 2, TestClass.after_status_created.count
    assert_equal 3, TestClass.after_or_status_created.count

    assert_equal 1, TestClass.before_status_processing.count
    assert_equal 2, TestClass.before_or_status_processing.count
    assert_equal 1, TestClass.after_status_processing.count
    assert_equal 2, TestClass.after_or_status_processing.count

    assert_equal 2, TestClass.before_status_finished.count
    assert_equal 3, TestClass.before_or_status_finished.count
    assert_equal 0, TestClass.after_status_finished.count
    assert_equal 1, TestClass.after_or_status_finished.count
  end
end
