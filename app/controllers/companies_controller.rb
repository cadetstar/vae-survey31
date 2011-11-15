class CompaniesController < ApplicationController
  before_filter :authenticate_user!

  def index
    setup_session_defaults_for_controller(:company)

    @companies = build_query(Company, :company)
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(params[:company])

    if @company.save
      flash[:notice] = 'Company created.'
      redirect_to companies_path
    else
      flash[:error] = 'There were errors with the creation.'
      redirect_to new_company_path
    end
  end

  def edit
    unless @company = Company.find_by_id(params[:id])
      flash[:error] = 'I could not find a company with that ID.'
      redirect_to companies_path
    end
  end

  def update
    unless @company = Company.find_by_id(params[:id])
      flash[:error] = 'I could not find a company with that ID.'
      redirect_to companies_path
    end

    if @company.update_attributes(params[:company])
      flash[:notice] = 'Company updated.'
      redirect_to @company
    else
      flash[:error] = 'There was a problem updating the company.'
      redirect_to edit_company_path(@company)
    end
  end

  def show
    unless @company = Company.find_by_id(params[:id])
      flash[:error] = 'I could not find a company with that ID.'
      redirect_to companies_path
    end
  end
end