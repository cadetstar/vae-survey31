module ApplicationHelper
  def list_of_groups(property)
    if property.id
      Group.order(:name).all.collect{|g| [g,g.id]}
    else
      [["Create new Group",-1]]+Group.order(:name).all.collect{|g| [g,g.id]}
    end
  end

  def cif_restrictor
    raw %w(Unsent Flagged Sent Captured Completed All).reject{|c| session[:cifs][:status] == c}.collect{|c| link_to c, cifs_path(:status => c.downcase)}
  end

  def restrict_filter(filter_name, descriptor)
    if session[:thank_you_cards][:restrict] != filter_name
      "<li>#{link_to descriptor, thank_you_cards_path(:restrict => filter_name)}</li>"
    end
  end

  def scope_filter(scope_name, descriptor)
    if session[:thank_you_cards][:scope] != scope_name
      "<li>#{link_to descriptor, thank_you_cards_path(:scope => scope_name)}</li>"
    end
  end

  def token_helper
    raw <<-OUTPUT
    <div>
      <div name='header'><a href='#' onclick="flipMe(this,'body');return false;">View Token Help.</a></div>
      <div name='body' style='display: none;'>
        <a href='#' onclick="flipMe(this,'header')">Collapse Token Help.</a><br />
        %CID% - Inserts the proper inline image tag<br />
        %FULL_SALUTATION% - The client's full name with salutation<br />
        %PLAIN_TEXT_INSERT% - Plain text version of the fields for a thank you card.<br />
        %PROPERTY_SIGNOFF% - The signoff for the property<br />
        %GREETING_URL% - The url where a recipient can view their greeting card image.
      </div>
    </div>
    OUTPUT
  end

  def system_fonts
    Dir.glob("C:/Windows/Fonts/*").collect{|f| f.gsub("C:/Windows/Fonts/",'')}
  end

  def template_tokens
    raw <<-OUTPUT
    <div>
      <div name='header'><a href='#' onclick="flipMe(this,'body');return false;">View Token Help.</a></div>
      <div name='body' style='display: none;'>
        <a href='#' onclick="flipMe(this,'header')">Collapse Token Help.</a><br />
          %PADnum% - Add num padding<br />
          %PROP_POST_PADnum% - Insert the property post text and pad, if text is present<br />
          %PROP_POST% - Insert the property post text<br />
          %PROP_PRE_PADnum% - Insert the property pre text and pad, if text is present<br />
          %PROP_PRE% - Insert the property pre text<br />
          %PROP_GREETING_PADnum% - Insert the greeting from the thank you card and pad, if text is present<br />
          %PROP_GREETING% - Insert the greeting from the thank you card<br />
          %SEASON_PRE_PADnum% - Insert the season pre text and pad, if text is present<br />
          %SEASON_PRE% - Insert the season pre text<br />
          %SEASON_POST_PADnum% - Insert the season post text and pad, if text is present<br />
          %SEASON_POST% - Insert the season post text<br />
          %CLIENT_SALUTATION_PADnum% - Inserts the clients full name and pads, if text is present<br />
          %CLIENT_SALUTATION% - Inserts the clients full name<br />
              <br />
              %ALIGN_CENTER% - Aligns text for that line centered<br />
          %ALIGN_LEFT% - Aligns text for that line to the left<br />
          %ALIGN_RIGHT% - Aligns text for that line to the right<br />
          %SIZE_num% - Sets font size for that line to num<br />
          %AT_num1_num2% - Sets whatever else is on that line at position [num1,num2]<br />
          %IMAGE[filename|width|height]% - Inserts an image<br />
          %INLINE% - Turn on inline formatting<br />
          <br />
          ~START_BLOCK(num1,num2,num3,num4)~...~END_BLOCK~ - Inserts a bounding box of size num1xnum2 at [num3,num4]
      </div>
    </div>
    OUTPUT
  end

  def filter_helper(controller_sym)
    content_tag :div do
      form_tag({:controller => controller_sym.pluralize, :action => :index}, :method => :get) do
        content_tag :div do
            raw("Filter: ") + text_field_tag(:name_restrict, session[controller_sym][:name]) +
            select_tag(:property_id, options_for_select([["All Properties", 0]]+Property.list_for_select(current_user), session[controller_sym][:property_id])) +
            submit_tag('Filter')
        end
      end
    end
  end

  def show_hash(type)
    case type
      when :clent
        {'Company' => :company, 'First Name' => :first_name, 'Last Name' => :last_name, 'Email' => :email, 'Salutation' => :salutation, 'Phone' => :phone, 'R2 Client ID' => :r2_client_id}
      when :company
        {'Name' => :name, 'Address Line 1' => :address_line_1, 'Address Line 2' => :address_line_2, 'City' => :city, 'State' => :state, 'Zip' => :zip}
      when :prop_season
        {'Property' => :property, 'Season' => :season, 'Property Pre Text' => :property_pre_text, 'Property Post Text' => :property_post_text, 'Property Signoff' => :property_signoff}
      when :property
        {'Code' => :code, 'Name' => :name, 'Manager' => :manager, 'Supervisor' => :supervisor}
      when :season
        {'Name' => :name, 'Subject Line' => :subject, 'First Paragraph of Email' => :pre_text, 'Last Paragraph of Email' => :post_text, 'Property Character Limit' => :property_char_limit, 'HTML Template' => :email_template, 'Plain Template' => :email_template_plain}
    end
  end

  def sort_helper(model_sym, field_sym, title = nil)
    title ||= field_sym.to_s.titleize
    session[:sorters] ||= {}
    session[:sorters][model_sym] ||= {}
    link_to title, url_for({:controller => model_sym.to_s.pluralize, :action => :index, :sort_by => field_sym, :sort_order => (session[:sorters][model_sym][:field] == field_sym ? (session[:sorters][model_sym][:order] == 'ASC' ? 'DESC' : 'ASC') : 'ASC')})
  end

  def cif_class(cif)
    unless cif.sendable?
      "class='nosend'"
    else
      if cif.flagged?
        if cif.has_been_updated
          "class='updated_flagged'"
        else
          "class='flagged'"
        end
      else
        ''
      end
    end
  end
end

module ActionView
  module Helpers
    module FormHelper
      def date_field(object_name, method, options = {})
       raw <<-OUTPUT
          #{tag = text_field(object_name, method, options)}
          <script type="text/javascript">
          $(document).ready(function(ev) {
            $("##{tag.match(/id="([^"]+)"/)[1]}").datepicker({showOtherMonths: true, selectOtherMonths: true});
          })
          </script>
        OUTPUT
      end
    end

    module FormTagHelper
      def date_field_tag(name, value = nil, options = {})
        raw <<-OUTPUT
        #{tag :input, { "type" => "text", "name" => name, "id" => sanitize_to_id(name), "value" => value }.update(options.stringify_keys)}
          <script type="text/javascript">
          $(document).ready(function(ev) {
            $("##{sanitize_to_id(name)}").datepicker({showOtherMonths: true, selectOtherMonths: true, dateFormat: 'yy-mm-dd'});
          })
          </script>
        OUTPUT
      end
    end

    class FormBuilder
      def date_field(method, options = {})
        @template.send(
          'date_field',
          @object_name,
          method,
          objectify_options(options))
      end
    end
  end
end

