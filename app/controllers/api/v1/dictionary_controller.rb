# frozen_string_literal: true

module Api::V1
  class DictionaryController < ApplicationController
    protect_from_forgery with: :null_session

    def roles
      render_json(true, Role.all_cached)
    end

    def info_types
      render_json(true, InfoType.all_cached)
    end

    def relation_types
      render_json(true, RelationType.all_cached)
    end

    def sex
      render_json(true, Sex.all_cached)
    end
  end
end
