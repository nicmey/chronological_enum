# frozen_string_literal: true

require 'test_helper'

ActiveRecord::Schema.define do
  create_table :dummy_class_with_suffixes, force: true do |t|
    t.integer :status
  end
end

class DummyClassWithSuffix < ActiveRecord::Base
  enum status: { created: 0, processing: 1, finished: 2 }, _suffix: true, _temporal: true
end

class TemporalEnumWithPrefixTest < Minitest::Test
  def test_scopes_with_suffix_are_correct
    DummyClassWithSuffix.create(status: 'created')
    DummyClassWithSuffix.create(status: 'processing')
    DummyClassWithSuffix.create(status: 'finished')

    assert_equal 1, DummyClassWithSuffix.created_status.count
    assert_equal 1, DummyClassWithSuffix.processing_status.count
    assert_equal 1, DummyClassWithSuffix.finished_status.count

    assert_equal 0, DummyClassWithSuffix.before_created_status.count
    assert_equal 1, DummyClassWithSuffix.before_or_created_status.count
    assert_equal 2, DummyClassWithSuffix.after_created_status.count
    assert_equal 3, DummyClassWithSuffix.after_or_created_status.count

    assert_equal 1, DummyClassWithSuffix.before_processing_status.count
    assert_equal 2, DummyClassWithSuffix.before_or_processing_status.count
    assert_equal 1, DummyClassWithSuffix.after_processing_status.count
    assert_equal 2, DummyClassWithSuffix.after_or_processing_status.count

    assert_equal 2, DummyClassWithSuffix.before_finished_status.count
    assert_equal 3, DummyClassWithSuffix.before_or_finished_status.count
    assert_equal 0, DummyClassWithSuffix.after_finished_status.count
    assert_equal 1, DummyClassWithSuffix.after_or_finished_status.count
  end
end
