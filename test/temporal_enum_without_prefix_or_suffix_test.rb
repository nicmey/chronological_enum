# frozen_string_literal: true

require 'test_helper'

class TemporalEnumWithoutPrefixOrSuffixTest < Minitest::Test
  ActiveRecord::Schema.define do
    create_table :my_classes, force: true do |t|
      t.integer :status
    end
  end

  class MyClass < ActiveRecord::Base
    extend TemporalEnum

    enum status: { created: 0, processing: 1, finished: 2 }
    temporal_enum(:status)
  end

  def test_scopes_without_prefix_or_suffix_are_correct
    MyClass.create(status: 'created')
    MyClass.create(status: 'processing')
    MyClass.create(status: 'finished')

    assert_equal 1, MyClass.created.count
    assert_equal 1, MyClass.processing.count
    assert_equal 1, MyClass.finished.count

    assert_equal 0, MyClass.before_created.count
    assert_equal 1, MyClass.before_or_created.count
    assert_equal 2, MyClass.after_created.count
    assert_equal 3, MyClass.after_or_created.count

    assert_equal 1, MyClass.before_processing.count
    assert_equal 2, MyClass.before_or_processing.count
    assert_equal 1, MyClass.after_processing.count
    assert_equal 2, MyClass.after_or_processing.count

    assert_equal 2, MyClass.before_finished.count
    assert_equal 3, MyClass.before_or_finished.count
    assert_equal 0, MyClass.after_finished.count
    assert_equal 1, MyClass.after_or_finished.count
  end
end
