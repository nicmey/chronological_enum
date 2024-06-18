# frozen_string_literal: true

require 'test_helper'

ActiveRecord::Schema.define do
  create_table :dummy_class_with_prefixes, force: true do |t|
    t.integer :status
  end
end

class DummyClassWithPrefix < ActiveRecord::Base
  enum status: { created: 0, processing: 1, finished: 2 }, _prefix: true, _chronological: true
end

class ChronologicalEnumWithPrefixTest < Minitest::Test
  def test_scopes_with_prefix_are_correct
    DummyClassWithPrefix.create(status: 'created')
    DummyClassWithPrefix.create(status: 'processing')
    DummyClassWithPrefix.create(status: 'finished')

    assert_equal 1, DummyClassWithPrefix.status_created.count
    assert_equal 1, DummyClassWithPrefix.status_processing.count
    assert_equal 1, DummyClassWithPrefix.status_finished.count

    assert_equal 0, DummyClassWithPrefix.before_status_created.count
    assert_equal 1, DummyClassWithPrefix.before_or_status_created.count
    assert_equal 2, DummyClassWithPrefix.after_status_created.count
    assert_equal 3, DummyClassWithPrefix.after_or_status_created.count

    assert_equal 1, DummyClassWithPrefix.before_status_processing.count
    assert_equal 2, DummyClassWithPrefix.before_or_status_processing.count
    assert_equal 1, DummyClassWithPrefix.after_status_processing.count
    assert_equal 2, DummyClassWithPrefix.after_or_status_processing.count

    assert_equal 2, DummyClassWithPrefix.before_status_finished.count
    assert_equal 3, DummyClassWithPrefix.before_or_status_finished.count
    assert_equal 0, DummyClassWithPrefix.after_status_finished.count
    assert_equal 1, DummyClassWithPrefix.after_or_status_finished.count
  end
end
