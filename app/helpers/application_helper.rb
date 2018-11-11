# frozen_string_literal: true

module ApplicationHelper
  def simple_time_select_options
    minutes = %w[00 15 30 45]
    hours = (0..23).to_a.map { |h| format('%.2d', h) }
    options = hours.map do |h|
      minutes.map { |m| "#{h}:#{m}" }
    end.flatten
    options_for_select(options)
  end

  delegate :current_cart, to: :current_user

  def nav_bar(classes = 'nav navbar-nav')
    content_tag(:ul, class: classes) do
      yield
    end
  end

  def markdown(text)
    options = {
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: 'nofollow', target: '_blank' },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      autolink: true,
      superscript: true,
      disable_indented_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end

  def nav_link(text, path, options = { class: '' })
    options[:class].prepend(current_page?(path) ? 'active ' : '')
    content_tag(:li, options) do
      link_to text, path
    end
  end

  # currently busted. gotta figure out why never descending
  def sortable(column, title = nil)
    title ||= column.titleize
    sort_direction = params['direction']
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to title, { sort: column, direction: direction }, { class: css_class }
  end

  # for building search forms, eventually
  def setup_search_form(builder)
    fields = builder.grouping_fields builder.object.new_grouping,
      object_name: 'new_object_name', child_index: 'new_grouping' do |f|
      render('grouping_fields', f: f)
    end

    content_for :document_ready, %{
      var search = new Search({grouping: "#{escape_javascript(fields)}"});
      $(document).on("click", "button.add_fields", function(e) {
        e.preventDefault();
        search.add_fields(this, $(this).data('fieldType'), $(this).data('content'));
        return false;
      });
      $(document).on("click", "button.remove_fields", function(e) {
        search.remove_fields(this);
        e.preventDefault();
        return false;
      });
      $(document).on("click", "button.nest_fields", function(e) {
        e.preventDefault();
        search.nest_fields(this, $(this).data('fieldType'));
        return false;
      });
    }.html_safe
  end

  def button_to_remove_fields
    tag.button 'Remove', class: 'remove_fields btn'
  end

  def button_to_add_fields(form, type)
    new_object = form.object.send("build_#{type}")
    name = "#{type}_fields"
    fields = f.send(name, new_object, child_index: "new_#{type}") do |builder|
      render(name, f: builder)
    end

    tag.button button_label[type], class: 'add_fields btn', 'data-field-type': type,
      'data-content': fields.to_s
  end

  def button_to_nest_fields(type)
    tag.button button_label[type], class: 'nest_fields btn', 'data-field-type': type
  end

  def button_label
    { value: 'Add Value',
      condition: 'Add Condition',
      sort: 'Add Sort',
      grouping: 'Add Condition Group' }.freeze
  end

end
