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
        force:  false,
        format: 'awesome_format'
      }
    end

    let(:s3_object)             { double }
    let(:s3_bucket_source)      { double }
    let(:s3_bucket_destination) { double }

    it 'calls .transfer on AWS' do
      expected_parameters = { from: s3_bucket_source, to: s3_bucket_destination, force: false, format: 'awesome_format' }
      S3ObjectsSync::AWS.should_receive(:transfer).with(s3_object, expected_parameters)

      S3ObjectsSync::TransferAsynchronously.new(s3_object, s3_bucket_settings).call
    end
  end
end
