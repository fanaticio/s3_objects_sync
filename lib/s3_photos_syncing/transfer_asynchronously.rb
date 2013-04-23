java_import java.util.concurrent.Callable
require 's3_photos_syncing/aws'

module S3PhotosSyncing
  class TransferAsynchronously
    include Callable

    def initialize(object, buckets)
      @object      = object
      @source      = buckets['source']
      @destination = buckets['destination']
    end

    def call
      AWS::transfer(@object, from: @source, to: @destination)
    end
  end
end
