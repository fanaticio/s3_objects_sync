require 's3_photos_syncing/processor'

module S3PhotosSyncing
  def self.run(configuration)
    Processor.new(configuration).run
  end
end
