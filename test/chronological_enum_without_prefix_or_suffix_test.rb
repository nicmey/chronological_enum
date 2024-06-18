# frozen_string_literal: true

require 'test_helper'

ActiveRecord::Schema.define do
  create_table :dummy_class_without_prefix_or_suffixes, force: true do |t|
    t.integer :status
    t.integer :cat
  end
end

class DummyClassWithoutPrefixOrSuffix < ActiveRecord::Base
  enum status: { created: 0, processing: 1, finished: 2 }, _chronological: true
end

class ChronologicalEnumWithoutPrefixOrSuffixTest < Minitest::Test
  def test_scopes_without_prefix_or_suffix_are_correct
    DummyClassWithoutPrefixOrSuffix.create(status: 'created')
    DummyClassWithoutPrefixOrSuffix.create(status: 'processing')
    DummyClassWithoutPrefixOrSuffix.create(status: 'finished')

    assert_equal 1, DummyClassWithoutPrefixOrSuffix.created.count
    assert_equal 1, DummyClassWithoutPrefixOrSuffix.processing.count
    assert_equal 1, DummyClassWithoutPrefixOrSuffix.finished.count

    assert_equal 0, DummyClassWithoutPrefixOrSuffix.before_created.count
    assert_equal 1, DummyClassWithoutPrefixOrSuffix.before_or_created.count
    assert_equal 2, DummyClassWithoutPrefixOrSuffix.after_created.count
    assert_equal 3, DummyClassWithoutPrefixOrSuffix.after_or_created.count

    assert_equal 1, DummyClassWithoutPrefixOrSuffix.before_processing.count
    assert_equal 2, DummyClassWithoutPrefixOrSuffix.before_or_processing.count
    assert_equal 1, DummyClassWithoutPrefixOrSuffix.after_processing.count
    assert_equal 2, DummyClassWithoutPrefixOrSuffix.after_or_processing.count

    assert_equal 2, DummyClassWithoutPrefixOrSuffix.before_finished.count
    assert_equal 3, DummyClassWithoutPrefixOrSuffix.before_or_finished.count
    assert_equal 0, DummyClassWithoutPrefixOrSuffix.after_finished.count
    assert_equal 1, DummyClassWithoutPrefixOrSuffix.after_or_finished.count
  end
end
