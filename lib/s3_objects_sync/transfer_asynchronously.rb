java_import java.util.concurrent.Callable
require 's3_objects_sync/aws'

module S3ObjectsSync
  class TransferAsynchronously
    include Callable

    def initialize(object, options)
      @object      = object
      @source      = options[:buckets][:source]
      @destination = options[:buckets][:destination]
      @file_format = options[:file_format]
      @force       = options[:force]
    end

    def call
      AWS::transfer(@object, from: @source, to: @destination, file_format: @file_format,force: @force)
    end
  end
end
