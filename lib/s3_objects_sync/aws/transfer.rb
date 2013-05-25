require 'aws-sdk'
require 's3_objects_sync/logger'

module S3ObjectsSync
  module AWS
    class Transfer
      def initialize(object, options)
        @object             = object
        @source_bucket      = options[:from]
        @destination_bucket = options[:to]
        @file_format        = options[:file_format]
        @force              = options[:force]
      end

      def can_copy?
        @force || !destination_object.exists?
      end

      def destination
        @destination ||= ::AWS::S3.new.buckets[@destination_bucket]
      end

      def destination_object
        @destination_object ||= destination.objects[@object.key]
      end

      def run
        unless valid_source_object?
          Logger.info("invalid extension #{source_object.key}")
          return
        end

        unless can_copy?
          Logger.info("already copied #{source_object.key}")
          return
        end

        Logger.info("copying #{source_object.key}")
        begin
          destination_object.copy_from(source_object.key, bucket: source, acl: :public_read)
          Logger.info("copied #{source_object.key}")
        rescue Exception => error
          Logger.error("error on copy #{source_object.key}: #{error}")
        end
      end

      def source
        @source ||= ::AWS::S3.new.buckets[@source_bucket]
      end

      def source_object
        @object
      end

      def valid_source_object?
        !! Regexp.new(@file_format).match(source_object.key)
      end
    end
  end
end
