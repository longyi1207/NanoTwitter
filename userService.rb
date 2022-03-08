require "bcrypt"
require_relative "models/user.rb"

module UserService
    include BCrypt

    def createUser(params = {})
        puts params
        if params[:username].blank? || params[:password1].blank? || params[:password2].blank?
            return false, "Please provide required information!"
        end

        if params[:password1] != params[:password2]
            return false, "Passwords do not match!"
        end
        
        password_hash = Password.create(params[:password1])
        user = User.where(name: params[:username], password: password_hash).first
        if user != nil
            return false, "User already exists!"
        end

        user = User.create(name: params[:username], password: password_hash, create_time:Time.now())
        return true, user
    end
end