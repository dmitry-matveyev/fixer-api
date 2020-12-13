# frozen_string_literal: true

class ReportService
  THRESHOLDS = [1.day, 7.days, 1.month, 1.year].freeze

  def call
    today_rate = rate_service_call

    diffs = THRESHOLDS.map do |offset|
      rate = rate_service_call(offset: offset)
      next if rate.blank?

      today_rate - rate
    end

    row = [today_rate] + diffs
    save_file(row.join(';'))
  end

  private

  def rate_service_call(offset: 0)
    date = Date.current - offset
    RateService.new(date).call
  end

  def save_file(data)
    file = File.new("/tmp/rates-#{Date.current}.csv", 'w')
    file.write data
    file.close
    puts file.path

    # or use https://github.com/aws/aws-sdk-ruby
    # options = {:acl => :public_read, :content_type => MIME::Types.type_for(filetype).first}
    # AWS::S3.new.buckets[APP_CONFIG['amazon_bucket_name']].objects[filename].write(data, options)
  end
end
