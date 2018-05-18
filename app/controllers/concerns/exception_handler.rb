module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
    rescue_from ActionController::ParameterMissing, with: :parameter_missing_response

    def render_unprocessable_entity_response(e)
      json_response({ message: e.record.errors }, :unprocessable_entity)
    end

    def render_not_found_response(e)
      json_response({ error: e.exception }, :not_found)
    end

    def parameter_missing_response(e)
      json_response({ error: e.exception }, :unprocessable_entity)
    end
  end
end
