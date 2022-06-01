# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ExceptionHandler

  def render_errors(object_with_errors, status: :unprocessable_entity)
    render(
      status:,
      json: {
        errors: object_with_errors.errors.as_json
      }
    )
  end
end
