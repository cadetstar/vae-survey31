class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all

  layout "application"

  RECORDS_PER_PAGE = 20

  def is_administrator?
    unless current_user and current_user.admin?
      flash[:error] = "You do not have permission for that page."
      redirect_to root_path
    end
  end
  
  def setup_session_defaults_for_controller(controller_sym)
    session[:sorters] ||= {}
    session[:sorters][controller_sym] ||= {}
    session[:sorters][controller_sym][:field] ||= :name
    session[:sorters][controller_sym][:order] ||= 'ASC'

    session[controller_sym] ||= {}
    session[controller_sym][:property_id] ||= 0
    session[controller_sym][:name] ||= ""
    session[controller_sym][:page_id] ||= 1

    if params[:name_restrict]
      session[controller_sym][:name] = params[:name_restrict]
    end

    if params[:property_id]
      session[controller_sym][:property_id] = params[:property_id].to_i
    end

    if params[:sort_by]
      session[:sorters][controller_sym][:field] = params[:sort_by].to_sym
      session[:sorters][controller_sym][:order] = params[:sort_order]
    end

    if params[:page_id]
      session[controller_sym][:page_id] = params[:page_id].to_i
    end

  end

  def build_query(model, controller_sym)
    build_it = model.order("#{session[:sorters][controller_sym][:field]} #{session[:sorters][controller_sym][:order]}")

    unless session[controller_sym][:name].blank?
      if session[controller_sym][:name].match(/%/)
        build_it = build_it.where(["name like ?", session[controller_sym][:name]])
      else
        build_it = build_it.where(["name like ?", "%#{session[controller_sym][:name]}%"])
      end
    end

    unless session[controller_sym][:property_id] == 0
      if current_user.admin? or current_user.all_properties.collect{|r| r.id}.include?(session[controller_sym][:property_id])
        build_it = build_it.where({:property_id => session[controller_sym][:property_id]})
      else
        build_it = build_it.where({:property => current_user.all_properties})
      end
    else
      unless current_user.admin?
        build_it = build_it.where({:property => current_user.all_properties})
      end
    end

    if session[controller_sym][:page_id] == 0
      session[controller_sym][:page_id] = 1
    elsif session[controller_sym][:page_id] > 1
      if (session[controller_sym][:page_id] - 1) * RECORDS_PER_PAGE > build_it.size
        session[controller_sym][:page_id] = 1
      end
    end

    build_it = build_it.page(session[controller_sym][:page_id])
    build_it
  end
end
