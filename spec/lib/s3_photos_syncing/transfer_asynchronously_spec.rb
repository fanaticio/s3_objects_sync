require 'spec_helper'
require 's3_objects_sync/transfer_asynchronously'

describe S3ObjectsSync::TransferAsynchronously do
  describe '#call' do
    let(:s3_bucket_settings) do
      {
        buckets: {
          source:      s3_bucket_source,
          destination: s3_bucket_destination
        },
        file_format: 'awesome_format',
        force:       false
      }
    end

    let(:s3_object)             { mock }
    let(:s3_bucket_source)      { mock }
    let(:s3_bucket_destination) { mock }

    it 'calls .transfer on AWS' do
      expected_parameters = { from: s3_bucket_source, to: s3_bucket_destination, file_format: 'awesome_format', force: false }
      S3ObjectsSync::AWS.should_receive(:transfer).with(s3_object, expected_parameters)

      S3ObjectsSync::TransferAsynchronously.new(s3_object, s3_bucket_settings).call
    end
  end
end
