require 'net/http'
require 'carrierwave'
require 'fog-aws'
require 'active_support'
require 'active_support/core_ext'
require 'tempfile'

Dir[ 'lib/**/*.rb' ].each { |path| require_relative path }

ReportService.new.call