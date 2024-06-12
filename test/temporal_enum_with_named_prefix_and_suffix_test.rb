# frozen_string_literal: true

require 'test_helper'

ActiveRecord::Schema.define do
  create_table :dummy_class_with_named_prefix_and_suffixes, force: true do |t|
    t.integer :status
  end
end

class DummyClassWithNamedPrefixAndSuffix < ActiveRecord::Base
  enum status: { created: 0, processing: 1, finished: 2 }, _prefix: 'prefix', _suffix: 'suffix', _temporal: true
end

class TemporalEnumWithNamedPrefixAndSuffixTest < Minitest::Test
  def test_with_named_prefix_scopes_are_correct
    DummyClassWithNamedPrefixAndSuffix.create(status: 'created')
    DummyClassWithNamedPrefixAndSuffix.create(status: 'processing')
    DummyClassWithNamedPrefixAndSuffix.create(status: 'finished')

    assert_equal 1, DummyClassWithNamedPrefixAndSuffix.prefix_created_suffix.count
    assert_equal 1, DummyClassWithNamedPrefixAndSuffix.prefix_processing_suffix.count
    assert_equal 1, DummyClassWithNamedPrefixAndSuffix.prefix_finished_suffix.count

    assert_equal 0, DummyClassWithNamedPrefixAndSuffix.before_prefix_created_suffix.count
    assert_equal 1, DummyClassWithNamedPrefixAndSuffix.before_or_prefix_created_suffix.count
    assert_equal 2, DummyClassWithNamedPrefixAndSuffix.after_prefix_created_suffix.count
    assert_equal 3, DummyClassWithNamedPrefixAndSuffix.after_or_prefix_created_suffix.count

    assert_equal 1, DummyClassWithNamedPrefixAndSuffix.before_prefix_processing_suffix.count
    assert_equal 2, DummyClassWithNamedPrefixAndSuffix.before_or_prefix_processing_suffix.count
    assert_equal 1, DummyClassWithNamedPrefixAndSuffix.after_prefix_processing_suffix.count
    assert_equal 2, DummyClassWithNamedPrefixAndSuffix.after_or_prefix_processing_suffix.count

    assert_equal 2, DummyClassWithNamedPrefixAndSuffix.before_prefix_finished_suffix.count
    assert_equal 3, DummyClassWithNamedPrefixAndSuffix.before_or_prefix_finished_suffix.count
    assert_equal 0, DummyClassWithNamedPrefixAndSuffix.after_prefix_finished_suffix.count
    assert_equal 1, DummyClassWithNamedPrefixAndSuffix.after_or_prefix_finished_suffix.count
  end
end
