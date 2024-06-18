# frozen_string_literal: true

require_relative 'chronological_enum/version'
require_relative 'chronological_enum/enum'

module ChronologicalEnum
  ActiveRecord::Enum.prepend(ChronologicalEnum::Enum)
end
