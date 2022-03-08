require "bcrypt"
require_relative "models/user.rb"

module Authentication
    include BCrypt

    def authenticate!
        unless session[:user]
            session[:original_request] = request.path_info
            redirect '/login'
        end
    end

    def authenticate(params = {})
        if params[:username].blank? || params[:password].blank?
            return false, "Please provide required information!"
        end
        
        # password_hash = Password.create(params[:password])
        user = User.where(name: params[:username]).first
        if user == nil || Password.new(user.password) != params[:password] 
            return false, "Wrong username or password!"
        else
            return true, user.slice(:id, :name)
        end
    end

    def redirect_to_original_request
        user = session[:user]
        original_request = session[:original_request]
        session[:original_request] = nil
        redirect original_request
    end
end