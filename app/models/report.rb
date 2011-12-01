require 'spreadsheet'
class Report < ActiveRecord::Base
  BAR_COLORS = %w(black red orange yellow blue green)
  TYPES = %w(Property\ Questions Summary Detail Composite\ Detail)
  PROPERTY_FORMAT = {:vae => {:title => "VAE Survey Results (English and French)",
                              :rows => [
                                  ["<span class='reporttabhead'>%RETURNED% Surveys Returned<br />%ACCESSED% Surveys Accessed<br />%TOTAL% Surveys Sent</span>",
                                   "Average Score<br />%RESULT_0%",
                                   "<span class='reporttabhead'>%RESPONSE_RATE% Reponse Rate</span>"],
                                  ["%Q1%<br />%RESULT_1%","%Q2%<br />%RESULT_2%","%Q3%<br />%RESULT_3%"],
                                  ["%Q4%<br />%RESULT_4%","%Q5%<br />%RESULT_5%","%Q6%<br />%RESULT_6%"],
                                  ["%Q7%<br />%RESULT_7%","%Q8%<br />%RESULT_8%","%Q9%<br />%RESULT_9%"]]},
                     :vae_conventions => {:title => "Conventions Survey Results",
                                          :rows => [
                                              ["<span class='reporttabhead'>%RETURNED% Surveys Returned<br />%ACCESSED% Surveys Accessed<br />%TOTAL% Surveys Sent</span>",
                                               "Average Score<br />%RESULT_0%",
                                               "<span class='reporttabhead'>%RESPONSE_RATE% Reponse Rate</span>"],
                                              ["%Q1%<br />%RESULT_1%","%Q2%<br />%RESULT_2%","%Q3%<br />%RESULT_3%"],
                                              ["%Q4%<br />%RESULT_4%","%Q5%<br />%RESULT_5%","%Q6%<br />%RESULT_6%"],
                                              ["%Q7%<br />%RESULT_7%","%Q8%<br />%RESULT_8%","%Q9%<br />%RESULT_9%"],
                                              ["%Q10%<br />%RESULT_10%","%Q11%<br />%RESULT_11%","%Q12%<br />%RESULT_12%"],
                                              ["%Q13%<br />%RESULT_13%","%Q14%<br />%RESULT_14%","%Q15%<br />%RESULT_15%"],
                                              [" &nbsp; ","%Q16%<br />%RESULT_16%"," &nbsp; "]]},
                     :csi => {:title => "CSI Survey Results",
                              :rows => [
                                  ["<span class='reporttabhead'>%RETURNED% Surveys Returned<br />%ACCESSED% Surveys Accessed<br />%TOTAL% Surveys Sent</span>",
                                   "Average Score<br />%RESULT_0%",
                                   "<span class='reporttabhead'>%RESPONSE_RATE% Reponse Rate</span>"],
                                  ["%Q1%<br />%RESULT_1%","%Q2%<br />%RESULT_2%","%Q3%<br />%RESULT_3%"],
                                  ["%Q4%<br />%RESULT_4%","%Q5%<br />%RESULT_5%","%Q6%<br />%RESULT_6%"],
                                  ["%Q7%<br />%RESULT_7%","%Q8%<br />%RESULT_8%","%Q9%<br />%RESULT_9%"],
                                  ["%Q10%<br />%RESULT_10%","%Q11%<br />%RESULT_11%","%Q12%<br />%RESULT_12%"],
                                  ["%Q13%<br />%RESULT_13%","%Q14%<br />%RESULT_14%","%Q15%<br />%RESULT_15%"]]}}

  COMMENTS = [['Date',                    :right,     15,   :formatted_end_date],
              ['Company',                 :right,     30,   :company],
              ['Client',                  :right,     30,   :client],
              ['Date Completed',          :right,     15,   :formatted_completed_date],
              ['AVG',                     :right,      8,   :formatted_average_score],
              ['O-SAT',                   :right,      8,   :overall_satisfaction],
              ['Internal Notes',          :comment,   40,   :notes],
              ['Employee Recognition',    :comment,   40,   :employee_comments],
              ['Client Comments',         :comment,   40,   :client_comments]]
  FORMATS = {:head => Spreadsheet::Format.new(:rotation => 80, :horizontal_align => :center, :vertical_align => :center, :weight => :bold),
             :quarter => Spreadsheet::Format.new(:rotation => 80, :horizontal_align => :center, :vertical_align => :center, :weight => :bold, :pattern_bg_color => :cyan, :pattern_fg_color => :cyan, :pattern => 1),
             :month1 => Spreadsheet::Format.new(:rotation => 80, :horizontal_align => :center, :vertical_align => :center, :weight => :bold, :pattern_bg_color => :yellow, :pattern_fg_color => :yellow, :pattern => 1),
             :month2 => Spreadsheet::Format.new(:rotation => 80, :horizontal_align => :center, :vertical_align => :center, :weight => :bold, :pattern_bg_color => :lime, :pattern_fg_color => :lime, :pattern => 1),
             :month3 => Spreadsheet::Format.new(:rotation => 80, :horizontal_align => :center, :vertical_align => :center, :weight => :bold, :pattern_bg_color => :silver, :pattern_fg_color => :silver, :pattern => 1),
             :year => Spreadsheet::Format.new(:rotation => 80, :horizontal_align => :center, :vertical_align => :center, :weight => :bold),
             :comment => Spreadsheet::Format.new(:horizontal_align => :left, :vertical_align => :top, :text_wrap => true,),
             :right => Spreadsheet::Format.new(:horizontal_align => :right, :vertical_align => :middle),
             :comment_body => Spreadsheet::Format.new(:horizontal_align => :left, :vertical_align => :top, :text_wrap => true, :top => true, :bottom => true),
             :right_body => Spreadsheet::Format.new(:horizontal_align => :right, :vertical_align => :top, :top => true, :bottom => true)}
  COLORS = {:month1 => Spreadsheet::Format.new(:pattern_bg_color => :yellow, :pattern_fg_color => :yellow, :pattern => 1, :horizontal_align => :center),
            :month2 => Spreadsheet::Format.new(:pattern_bg_color => :lime, :pattern_fg_color => :lime, :pattern => 1, :horizontal_align => :center),
            :month3 => Spreadsheet::Format.new(:pattern_bg_color => :silver, :pattern_fg_color => :silver, :pattern => 1, :horizontal_align => :center),
            :quarter => Spreadsheet::Format.new(:pattern_bg_color => :cyan, :pattern_fg_color => :cyan, :pattern => 1, :horizontal_align => :center),
            :year => Spreadsheet::Format.new(:horizontal_align => :center),
            :def => Spreadsheet::Format.new(:horizontal_align => :center),
            :left => Spreadsheet::Format.new(:horizontal_align => :left)}
  COLUMN_WIDTH = 6


  serialize :parameters

  belongs_to :user

  def perform
    k = Report.find_by_id(self.id)
    k.reload # Force it to update itself.
    TrackLogger.log("Running report #{k.id} with type: #{k.type_of_report} and parameters #{k.parameters.inspect}")
    case k.type_of_report.downcase
      when 'summary'
        k.do_summary
      when 'detail'
        k.do_detail
      when 'composite detail'
        k.do_composite
      when 'property questions'
        k.do_property_questions
    end
  end

  def do_composite
    end_time = begin Time.parse(self.parameters[:end_date]).at_end_of_month rescue Time.now.at_end_of_month end
    start_time = end_time.at_beginning_of_year
    properties = self.parameters[:properties]

    pdf = Prawn::Document.new(:page_layout => :portrait, :left_margin => 20, :right_margin => 20, :top_margin => 20, :bottom_margin => 20)

    pdf.pad_top(10) do
      pdf.text 'Summary of Comments', :align => :center, :size => 13
    end
    pdf.text ' '

    Cif.includes([{:client => :company}, :property]).where({:property_id => properties, :count_survey => true, :cif_captured => false, :end_date => (start_time..end_time)}).where('completed_at is not null').order('end_date, completed_at').each do |cif|
      pdf.group do
        pdf.text cif.property.to_s, :size => 10
        pdf.text "#{cif.company} - #{cif.client} - #{cif.end_date.to_s(:shortdate)}", :size => 8
        pdf.indent(30) do
          pdf.text cif.employee_comments.to_s.gsub(/[^0-9a-zA-Z,:@_~;!\$<>\?\+\(\)"'& \.\/-]/,' '), :size => 8
          pdf.dash(6, :space => 3, :phase => 0)
          pdf.pad(10) {pdf.stroke_horizontal_rule}
          pdf.text cif.client_comments.to_s.gsub(/[^0-9a-zA-Z,:@_~;!\$<>\?\+\(\)"'& \.\/-]/,' '), :size => 8
          pdf.undash
        end
        pdf.text ' '
        pdf.line_width = 3
        pdf.pad(10) {pdf.stroke_horizontal_rule}
        pdf.line_width = 1
        pdf.text ' '
      end
    end

    self.filename = "Summary_of_Comments_#{Time.now.to_s(:file_date)}.pdf"
    pdf.render_file(File.join(Rails.root.to_s, 'files', 'reports', self.filename))

    self.completed = true
    self.download = true
    self.save

  end

  def do_detail
    end_date = begin Time.parse(self.parameters[:end_date]) rescue Time.now end
    start_date = end_date.at_beginning_of_year
    properties = self.parameters[:properties]

    groups = Property.find_all_by_id(properties).collect{|r| r.group}.uniq.sort

    book = Spreadsheet::Workbook.new

    has_sheet = false
    groups.each do |group|
      has_sheet = true
      sheet = book.create_worksheet :name => group.name
      COMMENTS.each_with_index do |c,i|
        sheet[0,i] = c[0]
        sheet.column(i).default_format = FORMATS[c[1]]
        sheet.column(i).width = c[2]
      end

      Cif.order('end_date, completed_at').where({:property_id => group.property_ids, :count_survey => true, :cif_captured => false, :end_date => (start_date..end_date)}).where('completed_at is not null').each_with_index do |cif, a|
        COMMENTS.each_with_index do |c,i|
          sheet[a+1,i] = cif.send(c[3])
          sheet.row(a+1).set_format(i, FORMATS[c[1]])
        end
      end
    end

    unless has_sheet
      sheet = book.create_worksheet :name => "No properties selected."
    end

    self.filename = "Detail_#{Time.now.to_s(:file_date)}.xls"
    book.write(File.join(Rails.root.to_s, 'files', 'reports', self.filename))

    self.completed = true
    self.download = true
    self.save
  end

  def do_summary
    end_date = begin Time.parse(self.parameters[:end_date]) rescue Time.now end
    properties = self.parameters[:properties]

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet :name => 'CSP Results'

    sheet[0,0] = 'Property'

    groups = Property.find_all_by_id_and_cif_include(properties, true).collect{|r| r.group}.uniq.sort_by{|g| g.name.downcase}

    offset = 2
    groups.each_with_index do |g, i|
      sheet[offset+i,1] = g.report_property_codes
      sheet[offset+i,0] = g.name
    end

    sheet[offset + groups.size + 1,0] = 'TOTAL'

    end_date = end_date.at_end_of_month
    start_period = end_date.at_beginning_of_year

    column_index = 2
    quarter = '1st'

    (2..100).each do |i|
      sheet.column(i).width = COLUMN_WIDTH
    end

    sheet.column(0).default_format = COLORS[:left]
    sheet.column(0).width = 30
    sheet.column(1).default_format = COLORS[:def]
    sheet.column(1).width = 20

    end_period = end_date

    while start_period < end_period
      month_format = case start_period.month % 3
                       when 0; :month1
                       when 1; :month2
                       else;    :month3

                     end

      perform_for_time_period(start_period, start_period.at_end_of_month, groups, column_index, sheet, month_format, offset)
      column_index += 5
      start_period = start_period.next_month

      if start_period == start_period.at_beginning_of_quarter # Do the quarterly summaries
        perform_for_time_period(start_period.prev_month.at_beginning_of_quarter, start_period.prev_month.at_end_of_quarter, groups, column_index, sheet, :quarter, offset, start_period.prev_month.quarter)
        column_index += 5
      end
    end
    # Now do the end of Year things
    perform_for_time_period(end_date.at_beginning_of_year, end_date, groups, column_index, sheet, :year, offset, "#{end_date.strftime("%Y")}")

    self.filename = "Summary_#{Time.now.to_s(:file_date)}.xls"
    book.write(File.join(Rails.root.to_s, 'files', 'reports', self.filename))

    self.completed = true
    self.download = true
    self.save
  end

  def perform_for_time_period(start_time, end_time, groups, column_index, sheet, month_format, offset, descriptor = nil)
    descriptor ||= "#{start_time.strftime("%b %y")}"
    sheet[0,column_index] = "#{descriptor} # CIF Received"
    sheet[0,column_index + 1] = "#{descriptor} Response Rate"
    sheet[0,column_index + 2] = "#{descriptor} # CIF Sent"
    sheet[0,column_index + 3] = "#{descriptor} Overall Satisfaction"
    sheet[0,column_index + 4] = "#{descriptor} Average Score"
    (0..4).each do |k|
      sheet.row(0).set_format(column_index + k, FORMATS[month_format])
    end

    values = Group.where(:id => groups.collect{|g| g.id}).joins("LEFT JOIN properties ON (properties.group_id = groups.id and properties.cif_include = TRUE) LEFT JOIN cifs ON (cifs.property_id = properties.id and cifs.count_survey = TRUE and cifs.cif_captured = FALSE and cifs.created_at between '#{start_time}' and '#{end_time}' and sent_at is not null)").group("groups.id, groups.name")
    values = values.select("groups.id, groups.name, COUNT(completed_at) as received, COUNT(sent_at) as sent, CASE WHEN COUNT(sent_at) = 0 THEN 0 ELSE (100*CAST(COUNT(completed_at) as numeric)/COUNT(sent_at)) END as rate, CASE WHEN SUM(CASE WHEN COALESCE(overall_satisfaction,0) = 0 THEN 0 ELSE 1 END) = 0 THEN 0 ELSE ROUND((CAST(SUM(overall_satisfaction) as numeric) / SUM(CASE WHEN COALESCE(overall_satisfaction,0) = 0 THEN 0 ELSE 1 END)),2) END as overall, CASE WHEN SUM(CASE WHEN COALESCE(average_score,0) = 0 THEN 0 ELSE 1 END) = 0 THEN 0 ELSE ROUND(CAST((SUM(average_score) / SUM(CASE WHEN COALESCE(average_score,0) = 0 THEN 0 ELSE 1 END)) as numeric),2) END as average").order("LOWER(groups.name)")

    totals = {}
    [:received, :rate, :sent, :overall, :average].each do |field|
      totals[field] = 0
    end


    values.each_with_index do |v,i|
      totals[:received] += v.received.to_i
      sheet[i+offset,column_index] = v.received.to_i.zero? ? '-' : v.received.to_i
      totals[:rate] += v.rate.to_f * v.sent.to_i
      sheet[i+offset,column_index + 1] = v.sent.to_i.zero? ? '-' : sprintf('%.0f%%',v.rate)
      totals[:sent] += v.sent.to_i
      sheet[i+offset,column_index + 2] = v.sent.to_i.zero? ? '-' : v.sent
      totals[:overall] += v.overall.to_f * v.received.to_i
      sheet[i+offset,column_index + 3] = v.received.to_i.zero? ? '-' : v.overall
      totals[:average] += v.average.to_f * v.received.to_i
      sheet[i+offset,column_index + 4] = v.received.to_i.zero? ? '-' : v.average

      if v.sent == 0
        sheet[i+offset,column_index+1] = '-'
        sheet[i+offset,column_index+2] = '-'
      end
      if v.received == 0
        sheet[i+offset,column_index] = '-'
        sheet[i+offset,column_index+3] = '-'
        sheet[i+offset,column_index+4] = '-'
      end
    end

    sheet[offset + groups.size + 1,column_index] = totals[:received].to_i.zero? ? '-' : totals[:received]
    sheet[offset + groups.size + 1,column_index + 1] = totals[:sent].to_i.zero? ? '-' : sprintf('%.0f%%', totals[:rate] / totals[:sent])
    sheet[offset + groups.size + 1,column_index + 2] = totals[:sent].to_i.zero? ? '-' : totals[:sent]
    sheet[offset + groups.size + 1,column_index + 3] = totals[:received].to_i.zero? ? '-' : totals[:overall] / totals[:received]
    sheet[offset + groups.size + 1,column_index + 4] = totals[:received].to_i.zero? ? '-' : totals[:average] / totals[:received]

    (-1..(offset+groups.size+1)).each do |i|
      (0..4).each do |j|
        sheet.row(i+offset).set_format(column_index+j, COLORS[month_format])
      end
    end

  end

  def do_property_questions
    start_date = begin Time.parse(self.parameters[:start_date]) rescue 2.months.ago end
    end_date = begin Time.parse(self.parameters[:end_date]) rescue Time.now end
    properties = self.parameters[:properties]

    TrackLogger.log("Running report #{self.id} with property questions with dates of #{start_date} to #{end_date} and properties: #{properties.inspect}")

    in_excel = self.download

    cifs = Cif.joins(:property).includes(:property).where({:properties => {:cif_include => true}, :property_id => properties, :cif_captured => false, :count_survey => true, :created_at => (start_date..end_date)})
    cifs = cifs.where('sent_at is not null')

    answers = {}
    [:vae, :vae_conventions, :csi].each do |t|
      answers[t] = {}

      answers[t][:total] = 0
      answers[t][:completed] = 0
      answers[t][:accessed] = 0
      0.upto(16).each do |i|
        answers[t][i] = {}
        answers[t][i][:count] = 0
        answers[t][i][:sum] = 0
        answers[t][i][:slices] = {}
        (0..5).each do |k|
          answers[t][i][:slices][k] = 0
        end
      end
    end

    cifs.each do |cif|
      t = case cif.cif_form
            when 'vae_french'
              :vae
            else
              cif.cif_form.to_sym
          end

      answers[t][:total] += 1
      if cif.clicked_at
        answers[t][:accessed] += 1
      end

      if cif.completed_at
        answers[t][:completed] += 1

        1.upto(16).each do |i|
          answers[t][i][:sum] += cif.answers[i].to_i
          answers[t][i][:slices][cif.answers[i].to_i] += 1
          if cif.answers[i].to_i > 0
            answers[t][i][:count] += 1
          end
        end
        answers[t][0][:sum] += cif.average_score.to_f
        answers[t][0][:slices][cif.average_score.to_i] += 1
        if cif.average_score.to_f > 0
          answers[t][0][:count] += 1
        end
      end
    end

    # Now that we have the data, determine formatting
    TrackLogger.log("Just before splitting up...we have #{answers[:vae][:total]} total responses.  #{answers.inspect}")
    if in_excel
      book = Spreadsheet::Workbook.new

      [:vae, :vae_conventions, :csi].each do |form|
        if answers[form][:total] > 0
          sheet = book.create_worksheet :name => form.to_s.titleize

          format = Spreadsheet::Format.new(:text_wrap => true)
          sheet.column(0).default_format = format
          sheet.column(0).width = 70

          (1..10).each do |c|
            sheet.column(c).default_format = FORMATS[:right]
          end

          sheet[0,0] = "Results for #{form.to_s.titleize}"

          sheet[1,0] = "Properties:"
          start = 1
          Property.where(:id => properties, :cif_include => true, :cif_form => (form == :vae ? [:vae, :vae_french] : form)).order(:code).each do |r|
            sheet[start+=1,0] = r.to_s
          end
          sheet[start+=1,0] = "From: #{start_date}"
          sheet[start+=1,0] = "To: #{end_date}"

          questions = $QUESTIONS[form.to_s][:by_num]

          offset = start + 4

          sheet[offset-2,0] = "Average Score"
          sheet[offset-2,1] = ((answers[form][0][:count] == 0) ? 0 : answers[form][0][:sum].to_f / answers[form][0][:count])
          sheet[offset-2,2] = answers[form][0][:count]

          sheet[offset,0] = "Question"
          sheet[offset,1] = "Score"
          sheet[offset,2] = "Num of Responses"
          sheet[offset,3] = "0s"
          sheet[offset,4] = "1s"
          sheet[offset,5] = "2s"
          sheet[offset,6] = "3s"
          sheet[offset,7] = "4s"
          sheet[offset,8] = "5s"

          questions.keys.sort.each do |i|
            sheet[i+offset,0] = questions[i]
            sheet[i+offset,1] = ((answers[form][i][:count] == 0) ? 0 : answers[form][i][:sum].to_f / answers[form][i][:count])
            sheet[i+offset,2] = answers[form][i][:count]
            j = 0
            while j < 6
              sheet[i+offset,3+j] = answers[form][i][:slices][j]
              j += 1
            end
          end
        end
      end

      filename = "PQ_#{Time.now.to_s(:file_date)}.xls"

      book.write(File.join("#{Rails.root}", 'files', 'reports', filename))

      self.filename = filename
    else
      vae_output = ""
      vae_output << "<div class='report'>"

      [:vae, :vae_conventions, :csi].each do |form|
        if answers[form][:total] > 0
          vae_output << "<div class='report_header'><span>#{PROPERTY_FORMAT[form][:title]}</span><br />"
          vae_output << "for Properties:<br />"
          vae_output << "<div class='properties'>#{Property.find_all_by_id(properties, :order => :code).join(", ")}</div></div>"
          vae_output << "<div class='report_entry'><table class='report'>"

          first = true
          PROPERTY_FORMAT[form][:rows].each do |row|
            vae_output << "<tr>"
            row.each_with_index do |cell, i|
              vae_output << "<td #{(first and i.odd?) ? "style='vertical-align: middle;'" : ''}>#{process_cell(cell, answers, form)}</td>"
            end
            vae_output << "</tr>"
            first = false
          end
          vae_output << "</table></div>"
        end
      end
      vae_output << "</div>"
      self.results = vae_output
      TrackLogger.log("At the end of the requests: #{vae_output}")
    end
    self.completed = true
    self.save
  end

  def process_cell(text, answers, form)
    form_answers = answers[form]
    text.gsub!(/%ACCESSED%/, form_answers[:accessed].to_s)
    text.gsub!(/%RETURNED%/, form_answers[:completed].to_s)
    text.gsub!(/%TOTAL%/, form_answers[:total].to_s)
    text.gsub!(/%RESPONSE_RATE%/, form_answers[:total] == 0 ? '0%' : "#{sprintf('%.2f', 100*form_answers[:completed].to_f / form_answers[:total])}%")
    text.gsub!(/%RESULT_(\d+)%/) {score_display(form_answers[$1.to_i][:sum],form_answers[$1.to_i][:count], $1.to_i==0)}
    text.gsub!(/%Q(\d+)%/) {$QUESTIONS[form.to_s][:by_num][$1.to_i]}
    text
  end

  def score_display(sum, total, skip_total = false)
    total ||= 0
    sum ||= 0
    if total > 0
      score = sum.to_f / total
    else
      score = 0
    end
    <<-OUTPUT
      <span class='reportscores'>#{sprintf('%.2f', score)}</span><br />
      #{skip_total ? '' : "#{total} responses.<br />"}
      <div class='score_wrapper'>
        <div class="score_bar" style='background-color: #{Report.bar_color(score+0.3)};width: #{sprintf('%.0f', score * 20)}%;'> &nbsp; </div>
      </div>
    OUTPUT
  end

  def self.bar_color(num)
    BAR_COLORS[num.to_i]
  end
end
