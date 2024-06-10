# frozen_string_literal: true

require_relative "temporal_enum/version"
require "pry"

module TemporalEnum
  class Error < StandardError; end

  # in model it should be
  # extend TemporalEnum
  # temporal_enum(:enum_name)
  def temporal_enum(enum)
    add_enum_temporal_methods(enum)
  end

  private

  # handle suffix and prefix
  # it should be after_prefix_enum_name for example
  # trying to guess the prefix by inspecting the methods
  # raise an error unless

  def add_enum_temporal_methods(enum_name)
    send(enum_name.to_s.pluralize).each do |key, value|
      define_singleton_method "after_#{key}" do
        where("#{enum_name} > ?", value)
      end

      define_singleton_method "before_#{key}" do
        where("#{enum_name} < ?", value)
      end

      define_singleton_method "after_or_#{key}" do
        where("#{enum_name} >= ?", value)
      end

      define_singleton_method "before_or_#{key}" do
        where("#{enum_name} <= ?", value)
      end
    end
  end
end
