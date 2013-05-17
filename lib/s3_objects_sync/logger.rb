module S3ObjectsSync
  class Logger
    def self.error(message)
      write_message(:error, message)
    end

    def self.info(message)
      write_message(:info, message)
    end

    def self.format_message(type, message)
      datetime    = Time.now.strftime('[%Y-%d-%m - %H:%M:%S]')

      "#{datetime} - #{type} - #{message}"
    end

    def self.write_message(type, message)
      formatted_message = format_message(type, message)

      puts formatted_message
    end
  end
end
