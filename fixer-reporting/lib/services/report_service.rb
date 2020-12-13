# frozen_string_literal: true

class ReportService
  FORMATS = %i[csv]
  THRESHOLDS = [1.day, 7.days, 1.month, 1.year].freeze
  DEFAULT_TARGET = 'USD'

  def initialize(targets)
    self.targets = Array.wrap(targets).map(&:upcase)
    self.targets << DEFAULT_TARGET if targets.empty?
  end

  def call
    rows = []

    targets.each do |target_currency|
      today_rate = rate_service_call(target: target_currency)

      diffs = THRESHOLDS.map do |offset|
        rate = rate_service_call(target: target_currency, offset: offset)
        next if rate.blank?

        today_rate - rate
      end

      rows << [today_rate, *diffs]
    end

    FORMATS.each do |format|
      # TODO: move converter into separate class
      processor = self.method(:"#{format}")
      data = processor.call(rows)
      save_file(data: data, format: format)
    end
  end

  private

  attr_accessor :targets

  def rate_service_call(target:, offset: 0)
    date = Date.current - offset
    RateService.new(date: date, target: target).call
  end

  def save_file(data:, format:)
    file = File.new("/tmp/rates-#{Date.current}.#{format}", 'w')
    file.write data
    file.close
    puts file.path

    # or use https://github.com/aws/aws-sdk-ruby
    # options = {:acl => :public_read, :content_type => MIME::Types.type_for(filetype).first}
    # AWS::S3.new.buckets[APP_CONFIG['amazon_bucket_name']].objects[filename].write(data, options)
  end

  def csv(rows)
    rows.map {|r| r.join(';') }.join("\n")
  end
end
