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
    # trying to find if there is a prefix or a suffix
    # probably should be in a service or at least refacto
    enum_values = send(enum_name.to_s.pluralize).keys
    enum_scopes = methods.map(&:to_s).select do |method_name|
      enum_values.select { |enum_value| method_name.include? enum_value }.present?
    end

    # no _prefix, no _suffix
    expected_scopes = enum_values + enum_values.map { |enum_value| "not_#{enum_value}" }
    if (expected_scopes - enum_scopes).blank?
      prefix = false
      suffix = false
    end

    # _prefix: true
    expected_scopes = enum_values.map { |enum_value| "#{enum_name}_#{enum_value}" } +
                      enum_values.map { |enum_value| "not_#{enum_name}_#{enum_value}" }
    if (expected_scopes - enum_scopes).blank?
      prefix = true
      suffix = false
    end

    # _suffix: true
    expected_scopes = enum_values.map { |enum_value| "#{enum_value}_#{enum_name}" } +
                      enum_values.map { |enum_value| "not_#{enum_value}_#{enum_name}" }
    if (expected_scopes - enum_scopes).blank?
      prefix = false
      suffix = true
    end

    send(enum_name.to_s.pluralize).each do |key, value|
      method_name = if prefix
                      "#{enum_name}_#{key}"
                    elsif suffix
                      "#{key}_#{enum_name}"
                    else
                      key
                    end
      define_singleton_method "after_#{method_name}" do
        where("#{enum_name} > ?", value)
      end

      define_singleton_method "before_#{method_name}" do
        where("#{enum_name} < ?", value)
      end

      define_singleton_method "after_or_#{method_name}" do
        where("#{enum_name} >= ?", value)
      end

      define_singleton_method "before_or_#{method_name}" do
        where("#{enum_name} <= ?", value)
      end
    end
  end
end
