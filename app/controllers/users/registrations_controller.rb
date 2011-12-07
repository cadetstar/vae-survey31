class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :is_administrator?, :except => [:edit, :update]
  before_filter :authenticate_user!, :only => [:edit, :update]
  skip_before_filter :require_no_authentication


  def create
    build_resource

    if resource.save
      flash[:notice] = "User created."
      redirect_to users_path
    else
      flash[:error] = "User failed to save."
      redirect_to new_user_registration_path
    end
  end

  def index
    @users = User.order("inactive, username")
  end

  def admin_edit
    unless @user = User.find_by_id(params[:id])
      puts "I could not find a user with that ID."
      redirect_to users_path
    end
  end

  def admin_update
    unless @user = User.find_by_id(params[:id])
      puts "I could not find a user with that ID."
    else
      if params[:user][:password].blank?
        params = params.reject!{|k,v| k.to_s =~ /password/}
      end
      @user.update_attributes(params[:user])
      flash[:notice] = 'User updated'
    end
    redirect_to users_path
  end

  def enable
    # Reenables the user
    unless @user = User.find_by_id(params[:id])
      flash[:error] = "I could not find a user with that ID."
    else
      if @user.enabled
        flash[:notice] = "#{@user} is already enabled."
      else
        @user.update_attribute(:inactive, false)
        flash[:notice] = "#{@user} is now enabled."
      end
    end
    redirect_to users_path
  end

  def destroy
    # Deactivates the user
    unless @user = User.find(params[:id])
      flash[:error] = "I could not find a user with that ID."
    else
      unless @user.enabled
        flash[:notice] = "#{@user} is already disabled."
      else
        @user.update_attribute(:inactive, true)
        flash[:notice] = "#{@user} is now disabled."
      end
    end
    redirect_to users_path
  end
end