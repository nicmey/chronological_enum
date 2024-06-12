# frozen_string_literal: true

require 'active_support/concern'
require_relative 'temporal_enum/version'
require 'pry'
require 'temporal_enum/railtie' if defined?(Rails::Railtie)

module TemporalEnum
  extend ActiveSupport::Concern

  included do
  end

  class Error < StandardError; end

  def enum(name = nil, values = nil, **options)
    temporal = options[:_temporal]
    options.delete(:_temporal)
    super(name, values, **options)

    return unless temporal

    add_enum_temporal_methods(options.keys.first)
    check_enum_values!(options.keys.first)
  end

  private

  def add_enum_temporal_methods(enum_name)
    prefix, suffix = prefix_or_suffix(enum_name)

    send(enum_name.to_s.pluralize).each do |key, value|
      method_name = if prefix.present? && suffix.present?
                      "#{prefix}_#{key}_#{suffix}"
                    elsif prefix.present?
                      "#{prefix}_#{key}"
                    elsif suffix.present?
                      "#{key}_#{suffix}"
                    else
                      key
                    end

      scope "after_#{method_name}", -> { where("#{enum_name} > ?", value) }
      scope "before_#{method_name}", -> { where("#{enum_name} < ?", value) }
      scope "after_or_#{method_name}", -> { where("#{enum_name} >= ?", value) }
      scope "before_or_#{method_name}", -> { where("#{enum_name} <= ?", value) }
    end
  end

  # method name depends on if a prefix or a suffix is provided
  def prefix_or_suffix(enum_name)
    enum_values = send(enum_name.to_s.pluralize).keys
    enum_scopes = (methods - ActiveRecord::Base.methods).map(&:to_s).select do |method_name|
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

    # _prefix: string or _suffix: 'string'
    named_prefix_or_suffix = named_prefix_or_suffix(enum_scopes, enum_values)
    return named_prefix_or_suffix if named_prefix_or_suffix

    raise ArgumentError, "Cannot create temporal scopes for #{enum_name}"
  end

  def named_prefix_or_suffix(enum_scopes, enum_values)
    results = enum_scopes
    results.each { |res| res.gsub!('not_', '') }
    enum_values.each do |enum_value|
      results.each { |res| res.gsub!(enum_value, '') }
    end
    results.uniq! # can be 'prefix_' or '_suffix' or 'prefix__suffix'
    results = results.sole.split('_')
    case results.length
    when 1
      [results.first, nil]
    when 2
      [nil, results.last]
    when 3
      [results.first, results.last]
    end
  rescue Enumerable::SoleItemExpectedError
    nil
  end

  def check_enum_values!(enum_name)
    return if send(enum_name.to_s.pluralize).values.all? { |value| value.is_a? Integer }

    raise ArgumentError, "Values for #{enum_name} must be integer to be temporal"
  end
end
