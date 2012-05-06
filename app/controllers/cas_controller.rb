class CasController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :verify
  skip_before_filter :require_valid_user
  before_filter RubyCAS::Filter, :only => :verify

  def auth
    if params[:redirect]
      session[:post_cas_redirect] = params[:redirect]
    end

    redirect_to cas_verify_path
  end

  def verify
    # After redirection the session will contain information like this
    # {
    #    "cas_sent_to_gateway"=>false,
    #    "cas_validation_retry_count"=>0,
    #    "previous_redirect_to_cas"=>2011-07-30 11:08:02 +0200,
    #    "cas_user"=>"pdbaets",
    #    "cas_extra_attributes"=>{
    #      "uid"=>"pdbaets", "mail"=>"FirstName.LastName@UGent.be", "givenname"=>"Pieter",
    #      "surname"=>"De Baets", "objectClass"=>"ugentDictUser",
    #      "lastenrolled"=>"2010 - 2011", "ugentStudentID"=>"00801234"
    #    },
    #    "casfilteruser"=>"pdbaets", "cas_last_valid_ticket"=>nil
    # }

    # Don't save the ticket, it contains a singleton somewhere that can't be marshalled
    session[:cas_last_valid_ticket] = nil

    # Associate the new user with a website user
    u = User.find_or_create_by_ugent_id session["cas_extra_attributes"]["ugentStudentID"]
    u.name = session["cas_extra_attributes"]["givenname"] + ' ' + session["cas_extra_attributes"]["surname"]
    u.email = session["cas_extra_attributes"]["mail"]
    u.save
    session[:user_id] = u.id

    if session[:post_cas_redirect]
      redirect_to session[:post_cas_redirect]
    else
      redirect_to root_url
    end
  end

  def logout
    RubyCAS::Filter.logout(self, root_url)
  end
end
