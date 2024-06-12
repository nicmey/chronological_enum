# frozen_string_literal: true

require 'test_helper'

ActiveRecord::Schema.define do
  create_table :dummy_class_with_named_suffixes, force: true do |t|
    t.integer :status
  end
end

class DummyClassWithNamedSuffix < ActiveRecord::Base
  enum status: { created: 0, processing: 1, finished: 2 }, _suffix: 'suffix', _temporal: true
end

class TemporalEnumWithNamedSuffixTest < Minitest::Test
  def test_with_named_suffix_scopes_are_correct
    DummyClassWithNamedSuffix.create(status: 'created')
    DummyClassWithNamedSuffix.create(status: 'processing')
    DummyClassWithNamedSuffix.create(status: 'finished')

    assert_equal 1, DummyClassWithNamedSuffix.created_suffix.count
    assert_equal 1, DummyClassWithNamedSuffix.processing_suffix.count
    assert_equal 1, DummyClassWithNamedSuffix.finished_suffix.count

    assert_equal 0, DummyClassWithNamedSuffix.before_created_suffix.count
    assert_equal 1, DummyClassWithNamedSuffix.before_or_created_suffix.count
    assert_equal 2, DummyClassWithNamedSuffix.after_created_suffix.count
    assert_equal 3, DummyClassWithNamedSuffix.after_or_created_suffix.count

    assert_equal 1, DummyClassWithNamedSuffix.before_processing_suffix.count
    assert_equal 2, DummyClassWithNamedSuffix.before_or_processing_suffix.count
    assert_equal 1, DummyClassWithNamedSuffix.after_processing_suffix.count
    assert_equal 2, DummyClassWithNamedSuffix.after_or_processing_suffix.count

    assert_equal 2, DummyClassWithNamedSuffix.before_finished_suffix.count
    assert_equal 3, DummyClassWithNamedSuffix.before_or_finished_suffix.count
    assert_equal 0, DummyClassWithNamedSuffix.after_finished_suffix.count
    assert_equal 1, DummyClassWithNamedSuffix.after_or_finished_suffix.count
  end
end
