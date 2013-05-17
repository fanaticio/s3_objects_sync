require 's3_objects_sync/processor'

module S3ObjectsSync
  def self.run(configuration)
    Processor.new(configuration).run
  end
end
