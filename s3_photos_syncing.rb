#!/usr/bin/env jruby

require 'aws-sdk'
require 'singleton'
require 'YAML'

java_import java.util.concurrent.Executors
java_import java.util.concurrent.FutureTask
java_import java.util.concurrent.Callable

MAX_THREAD_COUNT = 42
SETTINGS_NAME    = File.join(File.dirname(__FILE__), "#{File.basename(__FILE__, '.rb')}.yml")
SETTINGS         = YAML.load_file(SETTINGS_NAME)

class Logger
  def self.file
    return @@file if defined?(@@file)

    logger_name = File.join(File.dirname(__FILE__), "#{File.basename(__FILE__, '.rb')}.log")
    @@file      = File.new(logger_name, 'w')
  end

  def self.info(message)
    write_message(:info, message)
  end

  def self.error(message)
    write_message(:error, message)
  end

  def self.write_message(type, message)
    formatted_message = format_message(type, message)

    puts formatted_message
  end

  def self.format_message(type, message)
    datetime    = Time.now.strftime('[%Y-%d-%m - %H:%M:%S]')

    "#{datetime} - #{type} - #{message}"
  end
end

module Aws
  def self.objects_from(source_bucket)
    s3     = AWS::S3.new
    source = s3.buckets[source_bucket]
    source.objects.with_prefix('photos')
  end

  def self.transfer(object, options={})
    unless object.key =~ /\.jp[e]?g$/i
      ::Logger.info("invalid extension #{object.key}")
      return
    end

    s3                 = AWS::S3.new
    source             = s3.buckets[options[:from]]
    destination        = s3.buckets[options[:to]]
    destination_object = destination.objects[object.key]

    if destination_object.exists?
      ::Logger.info("already copied #{object.key}")
      return
    end

    ::Logger.info("copying #{object.key}")
    begin
      destination_object.copy_from(object.key, bucket: source, acl: :public_read)
      ::Logger.info("copied #{object.key}")
    rescue Exception => error
      ::Logger.error("error on copy #{object.key}: #{error}")
    end
  end
end

class TransferAsynchronously
  include Callable

  def initialize(object, buckets)
    @object      = object
    @source      = buckets['source']
    @destination = buckets['destination']
  end

  def call
    Aws::transfer(@object, from: @source, to: @destination)
  end
end

def main
  ::Logger.info('Start syncing...')
  AWS.config(SETTINGS['authentication'])
  executor = Executors.newFixedThreadPool(MAX_THREAD_COUNT)
  Aws::objects_from(SETTINGS['buckets']['source']).each do |object|
    transfer_task = FutureTask.new(TransferAsynchronously.new(object, SETTINGS['buckets']))
    executor.execute(transfer_task)
  end

  executor.shutdown
end

main
