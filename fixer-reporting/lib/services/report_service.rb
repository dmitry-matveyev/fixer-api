# frozen_string_literal: true

class ReportService
  FORMATS = %i[csv].freeze
  THRESHOLDS = [1.day, 7.days, 1.month, 1.year].freeze
  DEFAULT_TARGET_CURRENCY = 'USD'
  DEFAULT_BASE_CURRENCY = 'EUR'
  HEADERS = %i[base target today yesterday week month year].freeze

  # the idea is not to stop the report if some values can not be received
  ERROR_MESSAGE = 'err'

  def initialize(target_currencies)
    self.target_currencies = Array.wrap(target_currencies).map(&:upcase)
    self.target_currencies << DEFAULT_TARGET_CURRENCY if target_currencies.empty?
  end

  def call
    rows = [HEADERS]

    target_currencies.each do |target_currency|
      rows << row(target_currency)
    end

    persist(rows)
  end

  private

  attr_accessor :target_currencies

  def row(target_currency)
    row = [DEFAULT_BASE_CURRENCY, target_currency]

    today_rate = request_rate(target: target_currency)
    if today_rate.blank?
      row << ERROR_MESSAGE
      return row
    else
      row << today_rate
    end

    THRESHOLDS.each do |offset|
      rate = request_rate(target: target_currency, offset: offset)
      row << (rate.present? ? today_rate - rate : ERROR_MESSAGE)
    end

    row
  end

  def persist(rows)
    FORMATS.each do |format|
      processor = method(:"#{format}")
      data = processor.call(rows)
      save_file(data: data, format: format)
    end
  end

  def request_rate(target:, offset: 0)
    date = Date.current - offset
    RateService.new(date: date, target: target, base: DEFAULT_BASE_CURRENCY).call
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

  # TODO: move converter into separate class
  def csv(rows)
    rows.map { |r| r.join(';') }.join("\n")
  end
end
