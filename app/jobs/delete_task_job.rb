# frozen_string_literal: true

class DeleteTaskJob < ApplicationJob
  queue_as :delete_tasks

  def perform(task_id:)
    task = Task.find(task_id)
    task.destroy
  end
end
