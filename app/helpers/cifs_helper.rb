module CifsHelper
  def get_title(form)
    case form
      when 'csi'
        'CSI Customer Experience Survey'
      else
        'VAE Customer Experience Survey'
    end
  end

  def get_intro_text(form)
    case form
      when 'csi'
        <<-CSI
          <p class="survey_center">Thank you for choosing Conference Systems to provide your audiovisual requirements during your recent meeting.</p>
          <p class="survey_center">We would appreciate it if you would take a few moments to rate the quality of the service we provided, so that we may better serve you in the future.</p>
        CSI
      when 'vae_french'
        <<-FRENCH
          <p class="survey_center">Merci d'avoir coisi Visual Aids Electronics pour satisfaire &#224 vos besoins en audiovisuel lors de votre r&#233cente r&#233union.</p>
          <p class="survey_center">Nous vous saurions gr&#233 de prendre quelques minutes pour &#233valuer la qualit&#233 du service que nous offrons afin que nous puissons mieux vous servir &#224 l'avenir.</p>

          <p class="survey_center"><%= image_tag 'high5.png', :width => '300' %></p>
        FRENCH
      else
        <<-VAE
          <p class="survey_center">Thank you for choosing Visual Aids Electronics to provide your audiovisual requirements during your recent meeting.</p>
          <p class="survey_center">We would appreciate it if you would take a few moments to rate the quality of the service we provided, so that we may better serve you in the future.</p>

          <p class="survey_center"><%= image_tag 'high5.png', :width => '300' %></p>
        VAE
    end
  end

  def print_questions(f, form)
    unless questions = $QUESTIONS[form]
      ''
    else
      output = ""
      questions[:radios].each do |k,v|
        output << "<tr><td class='header_left'>#{k}</td><td class='header_right'>5 being highest, 1 being lowest, NA = Not Applicable</td></tr>"
        v.each do |num,q|
          output << "<tr><td class='question'>#{q}</td><td class='answer'>"
          if num == 0
            output << f.check_box(:had_si) + " Simultaneous Interpretation<br />"
            output << f.check_box(:had_ar) + " Audience Response<br />"
            output << f.check_box(:had_ptt) + " Microphones</td></tr>"
          else
            [5,4,3,2,1].each do |a|
              output << f.radio_button("cif_answers_#{num}", a) << " #{a} "
            end
            output << f.radio_button("cif_answers_#{num}", 0) << " #{questions[:na] || "NA"}</td></tr> "
          end
        end
      end

      output << "<tr><td class='header_left'>#{questions[:facts][:title]}</td><td class='header_right'> &nbsp; </td></tr>"
      output << "<tr><td class='question'>#{questions[:facts][:number_of_meetings]}</td><td class='answer'>#{f.select :number_of_meetings, meetings_values}</td></tr>"
      output << "<tr><td class='question'>#{questions[:facts][:next_meeting]}</td><td class='answer'>#{f.date_field :next_meeting}</td></tr>"
      output << "<tr><td class='question'>#{questions[:facts][:please_contact]}</td><td class='answer'>#{f.radio_button :please_contact, true} Yes #{f.radio_button :please_contact, false} No</td></tr>"
      output << "<tr><td class='question'>#{questions[:facts][:submittor]}</td><td class='answer'>#{f.text_field :submittor}</td></tr>"
      output << "<tr><td class='question'>#{questions[:facts][:contact_info]}</td><td class='answer'>#{f.text_field :contact_info}</td></tr>"
      output << "<tr><td class='question'>#{questions[:facts][:employee_comments]}</td><td class='answer'>#{f.text_area :employee_comments}</td></tr>"
      output << "<tr><td class='question'>#{questions[:facts][:client_comments]}</td><td class='answer'>#{f.text_area :client_comments}</td></tr>"
      output
    end
  end

  def meetings_values
    [["1-5",'1'],['6-10','2'],['11-15','3']['16+','4']]
  end

  def get_results(cif)
    output = ""

    if cif.cif_form == 'csi'
      output << "<p>Services provided:<br /><ul><li>Simultaneous Interpretation: #{cif.had_si ? '<strong>YES</strong>' : 'NO'}</li>"
      output << "<li>Interactive Voting: #{cif.had_ar ? '<strong>YES</strong>' : 'NO'}</li>"
      output << "<li>Microphone: #{cif.had_ptt ? '<strong>YES</strong>' : 'NO'}</li></ul></p>"
    end

    output << "<table class='survey'>"
    questions = $QUESTIONS[cif.cif_form]
    questions[:radios].each do |k,v|
      output << "<tr><td class='header_left'>#{k}</td><td class='header_right' colspan='2'>5 being highest, 1 being lowest, NA = Not Applicable</td></tr>"
      v.each do |num,q|
        output << "<tr><td class='question'>#{q}</td><td class='response'>"
        next if num == 0
        a = cif.answers[num].to_i
        output << "#{a == 0 ? 'NA' : sprintf('%.2f', a)}</td>"
        output << "<td class='resp_graph'><div style='background-color: #{bar_color(a)};width: #{a*2}0%;'> &nbsp; </td></tr>"
      end
    end

    output << "<tr><td class='header_left'>#{$QUESTIONS[cif.cif_form][:facts][:title]}</td><td class='header_right' colspan='2'> &nbsp; </td></tr>"
    [:number_of_meetings, :next_meeting, :please_contact, :submittor, :contact_info, :employee_comments, :client_comments].each do |field|
      output << "<tr><td class='question'>#{$QUESTIONS[cif.cif_form][:facts][field]}</td><td class='answer' colspan='2'>#{get_field(cif, field)}</td></tr>"
    end
    raw output
  end

  def get_field(cif, field)
    case field
      when :next_meeting
        cif.send(field) ? cif.next_meeting.to_s(:shortdate) : 'No scheduled_meeting'
      when :please_contact
        cif.send(field) ? 'Yes' : 'No'
      when :employee_comments, :client_comments
        cif.send(field).to_s.gsub(/\n/, '<br />')
    end
  end

  def bar_color(num)
    %w(black red orange yellow blue green)[num.to_i]
  end
end