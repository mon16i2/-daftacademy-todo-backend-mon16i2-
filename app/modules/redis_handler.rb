# frozen_string_literal: true

require 'redis'
require 'redis-namespace'
require 'forwardable'

class RedisHandler
  extend Forwardable
  def_delegators :@redis, :set, :setex, :get, :del, :keys, :expire, :ping

  class << self
    attr_writer :redis_instance

    def redis_instance
      @redis_instance || Redis.new(redis_configuration)
    end

    private

    def redis_configuration
      {}.tap do |hsh|
        hsh[:url] = ENV.fetch('REDIS_URL')
      end
    end
  end

  def initialize(queue_name)
    @redis = Redis::Namespace.new(queue_name, redis: self.class.redis_instance)
  end
end
