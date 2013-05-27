java_import java.util.concurrent.Callable
require 's3_objects_sync/aws'

module S3ObjectsSync
  class TransferAsynchronously
    include Callable

    def initialize(object, options)
      @object      = object
      @source      = options[:buckets][:source]
      @destination = options[:buckets][:destination]
      @force       = options[:force]
      @format      = options[:format]
    end

    def call
      AWS::transfer(@object, from: @source, to: @destination, force: @force, format: @format)
    end
  end
end
