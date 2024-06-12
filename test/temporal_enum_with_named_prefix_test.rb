# frozen_string_literal: true

require 'test_helper'

ActiveRecord::Schema.define do
  create_table :dummy_class_with_named_prefixes, force: true do |t|
    t.integer :status
  end
end

class DummyClassWithNamedPrefix < ActiveRecord::Base
  enum status: { created: 0, processing: 1, finished: 2 }, _prefix: 'prefix', _temporal: true
end

class TemporalEnumWithNamedPrefixTest < Minitest::Test
  def test_with_named_prefix_scopes_are_correct
    DummyClassWithNamedPrefix.create(status: 'created')
    DummyClassWithNamedPrefix.create(status: 'processing')
    DummyClassWithNamedPrefix.create(status: 'finished')

    assert_equal 1, DummyClassWithNamedPrefix.prefix_created.count
    assert_equal 1, DummyClassWithNamedPrefix.prefix_processing.count
    assert_equal 1, DummyClassWithNamedPrefix.prefix_finished.count

    assert_equal 0, DummyClassWithNamedPrefix.before_prefix_created.count
    assert_equal 1, DummyClassWithNamedPrefix.before_or_prefix_created.count
    assert_equal 2, DummyClassWithNamedPrefix.after_prefix_created.count
    assert_equal 3, DummyClassWithNamedPrefix.after_or_prefix_created.count

    assert_equal 1, DummyClassWithNamedPrefix.before_prefix_processing.count
    assert_equal 2, DummyClassWithNamedPrefix.before_or_prefix_processing.count
    assert_equal 1, DummyClassWithNamedPrefix.after_prefix_processing.count
    assert_equal 2, DummyClassWithNamedPrefix.after_or_prefix_processing.count

    assert_equal 2, DummyClassWithNamedPrefix.before_prefix_finished.count
    assert_equal 3, DummyClassWithNamedPrefix.before_or_prefix_finished.count
    assert_equal 0, DummyClassWithNamedPrefix.after_prefix_finished.count
    assert_equal 1, DummyClassWithNamedPrefix.after_or_prefix_finished.count
  end
end
