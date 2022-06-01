# frozen_string_literal: true

require 'test_helper'

module ApiTests
  module DeleteAllTasksTests
    class CreateTest < ActionDispatch::IntegrationTest
      let(:make_request) { post '/api/tasks/delete_all' }

      describe 'Successful request' do
        let(:tasks) { create_list(:task, 3) }

        before do
          tasks
        end

        it 'schedules delete tasks jobs' do
          assert_enqueued_with(job: DeleteTaskJob, queue: 'delete_tasks') do
            make_request
          end

          assert_enqueued_jobs 3
        end

        it 'responds with accepted' do
          make_request
          assert_response :accepted
        end
      end
    end
  end
end
