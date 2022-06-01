# frozen_string_literal: true

require 'test_helper'

module ApiTests
  module TasksTests
    class DestroyTest < ActionDispatch::IntegrationTest
      let(:make_request) { delete "/api/tasks/#{task_id}" }

      describe 'Successful request' do
        let(:task) { create(:task) }
        let(:task_id) { task.id }

        before do
          task
        end

        it 'removes task' do
          assert_difference('Task.count', -1) do
            make_request
          end
        end

        it 'responds with no content' do
          make_request
          assert_response :no_content
        end
      end

      describe 'Task does not exist' do
        let(:task_id) { '1111111' }

        it 'responds with not found' do
          make_request
          assert_response :not_found
        end
      end
    end
  end
end
