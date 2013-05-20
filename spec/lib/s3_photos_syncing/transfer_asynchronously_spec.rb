require 'spec_helper'
require 's3_objects_sync/transfer_asynchronously'

describe S3ObjectsSync::TransferAsynchronously do
  describe '#call' do
    it 'calls .transfer on AWS' do
      s3_object             = mock
      s3_bucket_source      = mock
      s3_bucket_destination = mock
      s3_bucket_settings    = { buckets: { source: s3_bucket_source, destination: s3_bucket_destination }, force: false }

      S3ObjectsSync::AWS.should_receive(:transfer).with(s3_object, from: s3_bucket_source, to: s3_bucket_destination, force: false)

      instance = S3ObjectsSync::TransferAsynchronously.new(s3_object, s3_bucket_settings)
      instance.call
    end
  end
end
