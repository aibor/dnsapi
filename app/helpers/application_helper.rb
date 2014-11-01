module ApplicationHelper

  def notice_or_errors_tag(record = nil)
    content_tag :div, notice, class: 'alert alert-success' if notice
    content_tag :div, alert, class: 'alert alert-warning' if alert
    if record && record.errors.any?
      content_tag :div,
        record.errors.messages,
        class: 'alert alert-danger'
    end
  end


  def form_field_with_errors(form, record, attr, label_text)
    klass = "form-group#{' has-error' unless record.errors[attr].blank?}"
    content_tag :div, class: klass do
      concat "\n"
      concat form.label(attr, label_text, class: 'control-label')
      unless record.errors[attr].blank?
        concat "\n"
        concat content_tag(:span, record.errors[attr].first, class: 'label label-danger')
      end
      concat "\n"
      yield
    end
  end

end

