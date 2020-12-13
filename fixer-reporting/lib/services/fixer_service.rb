class FixerService
  URL = 'http://localhost:3000/api/rates/'
  TARGET = 'USD'

  def initialize(date)
    self.date = date
  end

  def call
    url = [URL, date].join
    response = request_rate(url)

    return unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).to_f
  end

  private

  attr_accessor :date

  def request_rate(url)
    uri = URI(url)
    params = { target: TARGET }
    uri.query = URI.encode_www_form(params)

    Net::HTTP.get_response(uri)
  end
end