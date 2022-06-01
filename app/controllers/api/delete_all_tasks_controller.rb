# frozen_string_literal: true

module Api
  class DeleteAllTasksController < ApplicationController
    def create
      Task.destroy_all_later!
      head :accepted
    end
  end
end
