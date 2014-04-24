require 'federation'
include Federator

class FederatorsController < ApplicationController
  def federator
    @creds = {}

    render :federator
  end

  def federate
    create_sts(params[:access_key], params[:secret_key])
    set_policy("*", :any)
    create_session(params[:user_name], 3600)
    url = create_federated_login_url

    flash[:notice] = url

    redirect_to :action => "federator"
  end
end
