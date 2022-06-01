# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/rails'

module TestHelpers
  def response_json
    ActiveSupport::JSON.decode @response.body
  end
end

module ActiveSupport
  class TestCase
    include TestHelpers
    include ActiveJob::TestHelper
    include FactoryBot::Syntax::Methods

    extend MiniTest::Spec::DSL

    parallelize(workers: :number_of_processors)
  end
end
