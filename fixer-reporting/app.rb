# frozen_string_literal: true

require 'net/http'
require 'active_support'
require 'active_support/core_ext'
require 'tempfile'

%i[config lib].each do |root|
  Dir["#{root}/**/*.rb"].each { |path| require_relative path }
end

ReportService.new(ARGV).call
