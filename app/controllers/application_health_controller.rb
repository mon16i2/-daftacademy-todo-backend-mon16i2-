# frozen_string_literal: true

class ApplicationHealthController < ActionController::API
  def index
    head :ok
  end
end
