# http://grosser.it/2012/02/04/do-not-show-i18n-missing-translation-tooltips-in-production/
# config/initializers/disable_i18n_tooltips.rb
# missing translations
# - Do not show tooltips in production/test
# - Do not raise ( speedup) for every missing translations
#I18n::Backend::Base.class_eval do
#  def translate_with_default(locale, key, options = {})
#    if options[:rescue_format] == :html && ['test','production'].include?(Rails.env)
#      default = key.to_s.gsub('_', ' ').gsub(/\b('?[a-z])/) { $1.capitalize }
#      options.reverse_merge!(default: default)
#    end
#    translate_without_default(locale, key, options)
#  end
#
#  alias_method_chain :translate, :default
#end
#module ActionView
#  module Helpers
#    module TranslationHelper
#      alias_method :translate_without_default :translate
#
#      def translate(key, options = {})
#        options.merge!(:default => "translation missing: #{key}") unless options.key?(:default)
#        translate_without_default(key, options)
#      end
#    end
#  end
#end
module ActionView
  # = Action View Translation Helpers
  module Helpers
    module TranslationHelper
      def translate(key, options = {})
        options[:default] = wrap_translate_defaults(options[:default]) if options[:default]

        # If the user has specified rescue_format then pass it all through, otherwise use
        # raise and do the work ourselves
        options[:raise] ||= ActionView::Base.raise_on_missing_translations

        raise_error = options[:raise] || options.key?(:rescue_format)
        unless raise_error
          options[:raise] = true
        end

        if html_safe_translation_key?(key)
          html_safe_options = options.dup
          options.except(*I18n::RESERVED_KEYS).each do |name, value|
            unless name == :count && value.is_a?(Numeric)
              html_safe_options[name] = ERB::Util.html_escape(value.to_s)
            end
          end
          translation = I18n.translate(scope_key_by_partial(key), html_safe_options)
          translation.respond_to?(:html_safe) ? translation.html_safe : translation
        else
          I18n.translate(scope_key_by_partial(key), options)
        end
      rescue I18n::MissingTranslationData => e
        raise e if raise_error

        keys = I18n.normalize_keys(e.locale, e.key, e.options[:scope])
        content_tag('span', keys.last.to_s.titleize, :class => 'translation_missing', :title => "translation missing: #{keys.join('.')}")
        keys.last.to_s.titleize
      end
      alias :t :translate
    end
  end
end
