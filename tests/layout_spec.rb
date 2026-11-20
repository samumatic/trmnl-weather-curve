# frozen_string_literal: true

require_relative 'support/layout_checks'

# Data that stretches the layout, drawn in every view on TRMNL OG and TRMNL X, landscape and portrait.
# The checks are in tests/support/layout_checks.rb; the forecasts are the fixtures plugin_spec.rb uses.
RSpec.describe 'Weather Curve layout' do
  def fixture(name) = JSON.parse(File.read(File.join(__dir__, 'fixtures', name)))

  # Open-Meteo answers by what is asked: the forecast with the UV index, or the UV index alone after the DWD.
  let(:mocks) do
    forecast = ->(request) { { json: fixture(request[:url].include?('hourly=') ? 'open-meteo-with-uv.json' : 'open-meteo-uv.json') } }
    { 'https://api.brightsky.dev/*' => { json: fixture('brightsky.json') }, 'https://api.open-meteo.com/*' => forecast }
  end

  # French, the longest labels ("100 % de risque de pluie"), with the UV index and a long place name.
  def long_french = { mocks:, custom_fields: { 'lat_lon' => '52.5200,13.4050', 'language' => 'fr', 'show_uv' => 'true',
                                               'location_name' => 'Saint-Rémy-de-Provence, Bouches-du-Rhône' } }
  # Fahrenheit and 12-hour times from Open-Meteo, with the UV index and a long place name.
  def fahrenheit = { mocks:, custom_fields: { 'lat_lon' => '40.7128,-74.0060', 'language' => 'en', 'units' => 'fahrenheit',
                                              'show_uv' => 'true', 'location_name' => 'Lake Havasu City, Arizona' } }
  # The weather service down: the empty state, in German.
  def no_forecast = { mocks: { '*' => { status: 500, body: '' } },
                      custom_fields: { 'lat_lon' => '52.5200,13.4050', 'language' => 'de' } }

  it_behaves_like 'a layout that holds up',
                  'long French labels' => :long_french, 'Fahrenheit and 12-hour times' => :fahrenheit,
                  'no forecast' => :no_forecast
end
