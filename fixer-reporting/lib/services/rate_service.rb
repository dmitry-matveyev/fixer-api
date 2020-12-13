# frozen_string_literal: true

class RateService
  URL = 'http://localhost:3000/api/rates/'

  def initialize(date:, target:, base:)
    self.date = date
    self.target = target
    self.base = base
  end

  def call
    url = [URL, date].join
    response = request_rate(url)

    return unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  private

  attr_accessor :date, :target, :base

  def request_rate(url)
    uri = URI(url)
    params = { target: target, base: base }
    uri.query = URI.encode_www_form(params)

    Net::HTTP.get_response(uri)
  end
end
