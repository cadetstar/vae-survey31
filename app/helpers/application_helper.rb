module ApplicationHelper
  def list_of_groups(property)
    if property.id
      Group.order(:name).all.collect{|g| [g,g.id]}
    else
      [["Create new Group",-1]]+Group.order(:name).all.collect{|g| [g,g.id]}
    end
  end

  def cif_restrictor
    %w(Unsent Flagged Sent Captured Completed All).reject{|c| session[:cifs][:status] == c}.collect{|c| link_to c, cifs_path(:status => c.downcase)}
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
    <<-OUTPUT
    <div>
      <div name='header'><a href='#' onclick="flipMe(this,'body');return false;">View Token Help.</a></div>
      <div name='body' style='display: none;'>
        <a href='#' onclick="flipMe(this,'header')">Collapse Token Help.</a><br />
        %CID% - CID token for image.  Used in the HTML form.  Should not be modified.
        %FULL_SALUTATION% - The client's full name with salutation
        %PLAIN_TEXT_INSERT% - Plain text version of the fields for a thank you card.
        %PROPERTY_SIGNOFF% - The signoff for the property
        %GREETING_URL% - The url where a recipient can view their greeting card image.
      </div>
    </div>
    OUTPUT
  end

  def filter_helper(controller_sym)
    content_tag :div do
      form_tag :url => companies_path do
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
            $("##{sanitize_to_id(name)}").datepicker({showOtherMonths: true, selectOtherMonths: true});
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

