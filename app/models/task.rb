# frozen_string_literal: true

class Task < ApplicationRecord
  enum status: %i[active inactive], _default: :inactive

  validates :name, presence: true
  validates :status, inclusion: { in: statuses.keys, message: :invalid }

  scope :ordered, -> { reorder(:id) }

  class << self
    def destroy_all_later!
      all.map(&:destroy_later!)
    end
  end

  def destroy_later!
    DeleteTaskJob.perform_later(task_id: id)
  end

  def status=(value)
    self[:status] = value
  rescue ArgumentError
    self[:status] = nil
  end
end
