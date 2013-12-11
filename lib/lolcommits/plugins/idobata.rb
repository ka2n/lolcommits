require 'rest_client'
require 'cloudapp_api'

module Lolcommits
  class Idobata < Plugin
    attr_accessor :endpoint

    def initialize(runner)
      super
      self.options << 'idobata_endpoint'
      self.options << 'cloudapp_email'
      self.options << 'cloudapp_pass'
    end

    def run
      return unless valid_configuration?

      repo = self.runner.repo.to_s
      if repo.empty?
        puts "Repo is empty, skipping upload"
      else
        user = configuration['cloudapp_email']
        pass = configuration['cloudapp_pass']
        idobata_endpoint = configuration['idobata_endpoint']

        # Upload to cloudapp
        CloudApp.authenticate user, pass

        # Get direct link
        drop = CloudApp::Drop.create :upload, :file => self.runner.main_image
        link = drop.url
        thumb_link = drop.data['thumbnail_url']

        # Post to idobata
        source = <<-TXT
        <a href="#{link}"><img src="#{thumb_link}.jpg" /></a>
        TXT
        RestClient.post(idobata_endpoint, :format => 'html', :source => source)
      end
    end

    def is_configured?
      !configuration["enabled"].nil? && configuration["idobata_endpoint"] && configuration["cloudapp_email"] && configuration["cloudapp_pass"]
    end

    def self.name
      'idobata'
    end
  end
end
