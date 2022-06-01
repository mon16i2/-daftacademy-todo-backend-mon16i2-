# frozen_string_literal: true

require 'test_helper'

module ApplicationHealthTests
  class IndexTest < ActionDispatch::IntegrationTest
    let(:make_request) { get '/healthy' }

    it 'returns ok' do
      make_request
      assert_response :success
    end
  end
end
