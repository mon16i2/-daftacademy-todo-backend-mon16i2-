# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :code_404
  end

  protected

  def code_404(_error)
    head :not_found
  end
end
