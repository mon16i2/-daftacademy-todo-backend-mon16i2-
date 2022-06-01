# frozen_string_literal: true

require 'test_helper'

module ApiTests
  module TasksTests
    class CreateTest < ActionDispatch::IntegrationTest
      let(:make_request) { post '/api/tasks', params: params }
      let(:params) do
        {
          name: 'New task'
        }
      end

      describe 'Successful request' do
        let(:new_task) { Task.last }
        let(:task_json) do
          {
            'id' => new_task.id,
            'name' => new_task.name,
            'status' => new_task.status,
            'created_at' => new_task.created_at.as_json
          }
        end

        it 'creates new task' do
          assert_difference('Task.count', 1) do
            make_request
          end
        end

        it 'creates new task with proper attributes' do
          make_request
          assert_equal 'New task', new_task.name
          assert new_task.inactive?
        end

        it 'responds with json including proper attributes' do
          make_request
          assert_equal response_json, task_json
        end

        it 'responds with created' do
          make_request
          assert_response :created
        end
      end

      describe 'Invalid parameters' do
        let(:params) do
          {
            name: ''
          }
        end
        let(:errors_json) do
          {
            'errors' => {
              'name' => ["can't be blank"]
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
