# frozen_string_literal: true

module Api
  class TasksController < ApplicationController
    def index
      @tasks = Task.ordered
    end

    def create
      if new_task.save
        render status: :created
      else
        render_errors(new_task)
      end
    end

    def update
      if task.update(update_params)
        head :no_content
      else
        render_errors(task)
      end
    end

    def destroy
      task.destroy
    end

    private

    def new_task
      @new_task ||= Task.new(create_params)
    end

    def task
      @task ||= Task.find(params[:id])
    end

    def create_params
      params.permit(:name)
    end

    def update_params
      params.permit(:name, :status)
    end
  end
end
