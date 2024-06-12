# frozen_string_literal: true

# require 'temporal_enum'

module TemporalEnum
  class Railtie < Rails::Railtie
    ActiveSupport.on_load(:active_record) do
      extend TemporalEnum
    end
  end
end
