# frozen_string_literal: true

require 'test_helper'

module ApiTests
  module TasksTests
    class IndexTest < ActionDispatch::IntegrationTest
      let(:make_request) { get '/api/tasks' }

      def task_attributes(task)
        task.slice(:id, :name, :status).merge(
          created_at: task.created_at.as_json
        )
      end

      describe 'Successful request' do
        let(:tasks) { create_list(:task, 3) }
        let(:tasks_json) do
          {
            'tasks' => tasks.map do |task|
              task_attributes(task)
            end
          }
        end

        before do
          tasks
        end

        it 'responds with json including proper attributes' do
          make_request
          assert_equal response_json, tasks_json
        end

        it 'responds with success' do
          make_request
          assert_response :success
        end
      end
    end
  end
end
