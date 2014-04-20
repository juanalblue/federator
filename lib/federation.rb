require 'rubygems'
require 'json'
require 'open-uri'
require 'cgi'
require 'aws-sdk'

module Federator
  def create_sts(access_key, secret_key)
    @sts = AWS::STS.new(:access_key_id => access_key, :secret_access_key => secret_key)
  end
  
  def set_policy(actions, resources)
    @policy = AWS::STS::Policy.new
    @policy.allow(:actions => actions,:resources => resources)
  end
  
  def create_session(username, duration)
    @session = @sts.new_federated_session(username, :policy => @policy, :duration => duration)
  end
  
  def create_federated_login_url(issuer_url = "https://login.anycompany.com/", 
                                 console_url = "https://console.aws.amazon.com/console", 
                                 signin_url = "https://signin.aws.amazon.com/federation"
                                 )
    
    session_json = {
      :sessionId => @session.credentials[:access_key_id],
      :sessionKey => @session.credentials[:secret_access_key],
      :sessionToken => @session.credentials[:session_token]
    }.to_json
    
    get_signin_token_url = signin_url + "?Action=getSigninToken&SessionType=json&Session=" + CGI.escape(session_json)
    returned_content = URI.parse(get_signin_token_url).read
    signin_token = JSON.parse(returned_content)['SigninToken']
    signin_token_param = "&SigninToken=" + CGI.escape(signin_token)
    
    issuer_param = "&Issuer=" + CGI.escape(issuer_url)
    destination_param = "&Destination=" + CGI.escape(console_url)
    
    login_url = signin_url + "?Action=login" + signin_token_param + issuer_param + destination_param
  end
end
