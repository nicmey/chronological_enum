# frozen_string_literal: true

require_relative 'temporal_enum/version'
require_relative 'temporal_enum/enum'

module TemporalEnum
  ActiveRecord::Enum.prepend(TemporalEnum::Enum)
end
