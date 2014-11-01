module DomainsHelper

  def zone_disabled_warning
    content_tag :span,
      t('.zone_disabled'),
      class: 'label label-danger',
      title: t('.enable_hint')
  end

end

