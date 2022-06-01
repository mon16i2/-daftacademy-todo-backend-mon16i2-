# frozen_string_literal: true

require 'test_helper'

module ApiTests
  module TasksTests
    class UpdateTest < ActionDispatch::IntegrationTest
      let(:make_request) { put "/api/tasks/#{task_id}", params: params }
      let(:task) { create(:task) }
      let(:task_id) { task.id }
      let(:params) do
        {
          name: 'Inactive task',
          status: 'inactive'
        }
      end

      before do
        task
      end

      describe 'Successful request' do
        it 'does not create new task' do
          assert_no_difference('Task.count') do
            make_request
          end
        end

        it 'updates task attributes' do
          make_request
          task.reload
          assert_equal 'Inactive task', task.name
          assert task.inactive?
        end

        it 'responds with no content' do
          make_request
          assert_response :no_content
        end
      end

      describe 'Task does not exist' do
        let(:task_id) { '123123123' }

        it 'responds with not found' do
          make_request
          assert_response :not_found
        end
      end

      describe 'Invalid parameters' do
        let(:params) do
          {
            name: '',
            status: 'abc'
          }
        end
        let(:errors_json) do
          {
            'errors' => {
              'name' => ["can't be blank"],
              'status' => ['is invalid']
            }
          }
        end

        it 'responds with json including proper errors' do
          make_request
          assert_equal response_json, errors_json
        end

        it 'responds with unprocessable entity' do
          make_request
          assert_response :unprocessable_entity
        end
      end
    end
  end
end
