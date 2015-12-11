# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"

class LogStash::Outputs::Twilio < LogStash::Outputs::Base
  config_name "twilio"

  config :sid, :validate => :string, :required => true
  config :secret, :validate => :string, :required => true
  config :accountId, :validate => :string, :required => true
  
  config :from, :validate => :string, :required => true
  config :to, :validate => :string, :required => true

  config :format, :validate => :string, :default => "${message}"

  public
  def register
  	require 'rest-client'
  end # def register

  public
  def receive(event)
    return unless output?(event)

    text = event.sprintf(@format)

    recipients = event.sprintf(@to).split(',')

    url = "https://https://#{@sid}:#{@secret}@api.twilio.com/2010-04-01/Accounts/#{@accountId}/Messages"

   	recipients.each do |recipient|

	    payload = {
	    	"From" => @from,
	    	"To" => recipient,
	    	"Body" => text
	    }

	    begin
	      RestClient.post(
	        url,
	        payload,
	        :accept => "application/xml",
	        :'User-Agent' => "logstash-output-twilio",
	        :content_type => "application/x-www-form-urlencoded") { |response, request, result, &block|
	          if response.code != 200
	            @logger.warn("Got a #{response.code} response: #{response}")
	          end
	        }
	    rescue Exception => e
	      @logger.warn("Unhandled exception", :exception => e,
	                   :stacktrace => e.backtrace)
	    end

	end

  end # def event
end # class LogStash::Outputs::Twilio
