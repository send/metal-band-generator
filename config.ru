require 'bundler'

Bundler.require

require './app.rb'

use Rack::Deflater

run MetalBandGenerator::Controller
