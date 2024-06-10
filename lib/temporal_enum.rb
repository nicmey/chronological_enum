# frozen_string_literal: true

require_relative 'temporal_enum/version'

module TemporalEnum
  class Error < StandardError; end

  # in model it should be like this
  # extend TemporalEnum
  # temporal_enum(:enum_name)
  def temporal_enum(enum)
    add_enum_temporal_methods(enum)
  end

  private

  def add_enum_temporal_methods(enum_name)
    prefix, suffix = retrieve_prefix_or_suffix(enum_name)

    send(enum_name.to_s.pluralize).each do |key, value|
      method_name = if prefix.present?
                      "#{prefix}_#{key}"
                    elsif suffix.present?
                      "#{key}_#{suffix}"
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

  # method name depends on if a prefix or a suffix is provided
  def retrieve_prefix_or_suffix(enum_name)
    enum_values = send(enum_name.to_s.pluralize).keys
    enum_scopes = methods.map(&:to_s).select do |method_name|
      enum_values.select { |enum_value| method_name.include? enum_value }.present?
    end

    # no _prefix, no _suffix
    expected_scopes = enum_values + enum_values.map { |enum_value| "not_#{enum_value}" }
    return [nil, nil] if (expected_scopes - enum_scopes).blank?

    # _prefix: true
    expected_scopes = enum_values.map { |enum_value| "#{enum_name}_#{enum_value}" } +
                      enum_values.map { |enum_value| "not_#{enum_name}_#{enum_value}" }
    return [enum_name, nil] if (expected_scopes - enum_scopes).blank?

    # _suffix: true
    expected_scopes = enum_values.map { |enum_value| "#{enum_value}_#{enum_name}" } +
                      enum_values.map { |enum_value| "not_#{enum_value}_#{enum_name}" }
    return [nil, enum_name] if (expected_scopes - enum_scopes).blank?

    named_prefix_or_suffix = named_prefix_or_suffix(enum_scopes, enum_values)

    # _prefix: 'string'
    if named_prefix_or_suffix && enum_scopes.any? { |scope| scope.start_with?(named_prefix_or_suffix) }
      return [named_prefix_or_suffix, nil]
    end

    # _suffix: 'string'
    if named_prefix_or_suffix && enum_scopes.any? { |scope| scope.end_with?(named_prefix_or_suffix) }
      return [nil, named_prefix_or_suffix]
    end

    raise "Cannot create scopes for #{enum_name}"
  end

  def named_prefix_or_suffix(enum_scopes, enum_values)
    enum_scopes.map do |enum_scope|
      enum_values.each { |enum_value| enum_scope.gsub!(enum_value, '') }
      enum_scope.gsub('not_', '').gsub('_', '')
    end.uniq.sole
  rescue Enumerable::SoleItemExpectedError
    nil
  end
end
