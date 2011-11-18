class ReportsController < ApplicationController
  before_filter :authenticate_user!

  def index

  end

  def request
    unless Report::TYPES.include?(params[:type])
      flash[:error] = 'That is not a valid report.'
      redirect_to reports_path
    else
      params[:properties] = (params[:properties].collect{|r| r.id} & Property.list_for_select(current_user).collect{|c| c[1]})
      unless params[:type] == 'Property Questions'
        params[:download] = true
      end
      @r = Report.create(:parameters => params, :download => params[:download], :type_of_report => params[:type])

      Delayed::Job.enqueue @r
    end
  end

  def pulse
    @report = Report.find_by_id(params[:id])
  end

  def report
    unless @report = Report.find_by_id(params[:id])
      flash[:error] = 'I could not find a report with that ID.'
      redirect_to reports_path
      return
    end
    if params[:download]
      send_file "files/#{@report.filename}", :filename => @report.type_of_report
    end
  end
end