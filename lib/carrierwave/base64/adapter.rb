module Carrierwave
  module Base64
    module Adapter
      def mount_base64_uploader(attribute, uploader_class, options = {})
        mount_uploader attribute, uploader_class, options

        define_method "#{attribute}=" do |data|
          send "#{attribute}_will_change!" if data.present?

          if data.is_a?(String) && data.strip.start_with?('data')
            super(Carrierwave::Base64::Base64StringIO.new(
              data.strip, options[:file_name] || 'file'
            ))
          elsif data.is_a?(Hash) && data.has_key?('src') && data['src'].start_with?('data')
            super(Carrierwave::Base64::Base64StringIO.new(
              data['src'].strip, options[:file_name] || 'file'
            ))
          else
            super(data)
          end


        end
      end

      def mount_base64_uploaders(attribute, uploader_class, options = {})
        mount_uploaders attribute, uploader_class, options

        define_method "#{attribute}=" do |data|
          if data.present? && data.is_a?(Array) && data.all? { |d| d.is_a?(String) } && data.all? { |d| d.strip.start_with?("data") }
            files = []
            data.each do |d|
              files << Carrierwave::Base64::Base64StringIO.new(
                d.strip, options[:file_name] || 'file'
              )
            end
            super(files)
          elsif data.present? && data.is_a?(Array) && data.all? { |d| d.is_a?(Hash) } && data.all? { |d| d.has_key?('src') } && data.all? { |d| d.strip.start_with?("data") }
            files = []
            data.each do |d|
              files << Carrierwave::Base64::Base64StringIO.new(
                data['src'].strip, options[:file_name] || 'file'
              )
            end
            super(files)
          else
            super([data])
          end
        end
      end

    end
  end
end
