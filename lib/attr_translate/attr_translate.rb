require 'active_support/concern'
require_relative './translation_attribute'

module AttrTranslate
  extend ActiveSupport::Concern

  class_methods do
    def attr_translate(*attrs)
      class_attribute :translated_attribute_names, :permitted_translated_attributes

      self.translated_attribute_names = attrs
      self.permitted_translated_attributes = [
        *self.ancestors
          .select { |klass| klass.respond_to?(:permitted_translated_attributes) }
          .map(&:permitted_translated_attributes),
        *attrs.product(I18n.available_locales)
          .map { |attribute, locale| :"#{attribute}_#{locale}" }
      ].flatten.compact

      attrs.each do |attr_name|
        define_method attr_name do |**params|
          read_json_translation(attr_name, params)
        end

        define_method "#{attr_name}=" do |value|
          write_json_translation(attr_name, value)
        end

        define_singleton_method "with_#{attr_name}_translation" do |value, locale = I18n.locale|
          quoted_translation_store = connection.quote_column_name("#{attr_name}_translations")
          translation_hash = { "#{locale}" => value }
          where("#{quoted_translation_store} @> :translation::jsonb", translation: translation_hash.to_json)
        end
      end

      send(:prepend, TranslationAttribute)
    end
    alias_method :attr_translates, :attr_translate

    def translates?
      true
    end

  end

  def disable_fallback
    toggle_fallback(false)
  end

  def enable_fallback
    toggle_fallback(true)
  end

  protected

  attr_reader :enabled_fallback

  def json_translate_fallback_locales(locale)
    return locale if enabled_fallback == false || !::I18n.respond_to?(:fallbacks)
    ::I18n.fallbacks[locale]
  end

  def read_json_translation(attr_name, locale = I18n.locale, **params)
    translations = public_send("#{attr_name}_translations") || {}

    available = Array(json_translate_fallback_locales(locale)).detect do |available_locale|
      translations[available_locale.to_s].present?
    end

    translation = translations[available.to_s]
    # Rescue from MissingInterpolationArgument
    # so the default behaviour doesn't change.
    begin
      ::I18n.interpolate(translation, params) if translation
    rescue ::I18n::MissingInterpolationArgument
      translation
    end
  end

  def write_json_translation(attr_name, value, locale = I18n.locale)
    translation_store = "#{attr_name}_translations"
    translations = public_send(translation_store) || {}
    public_send("#{translation_store}_will_change!") unless translations[locale.to_s] == value
    translations[locale.to_s] = value
    public_send("#{translation_store}=", translations)
    value
  end

  def respond_to_with_translates?(symbol, include_all = false)
    return true if parse_translated_attribute_accessor(symbol)
    respond_to_without_translates?(symbol, include_all)
  end

  def method_missing_with_translates(method_name, *args)
    translated_attr_name, locale, assigning = parse_translated_attribute_accessor(method_name)

    return method_missing_without_translates(method_name, *args) unless translated_attr_name

    if assigning
      write_json_translation(translated_attr_name, args.first, locale)
    else
      read_json_translation(translated_attr_name, locale)
    end
  end

  # Internal: Parse a translated convenience accessor name.
  #
  # method_name - The accessor name.
  #
  # Examples
  #
  #   parse_translated_attribute_accessor("title_en=")
  #   # => [:title, :en, true]
  #
  #   parse_translated_attribute_accessor("title_fr")
  #   # => [:title, :fr, false]
  #
  # Returns the attribute name Symbol, locale Symbol, and a Boolean
  # indicating whether or not the caller is attempting to assign a value.
  def parse_translated_attribute_accessor(method_name)
    return unless /\A(?<attribute>[a-z0-9_]+)_(?<locale>[a-z]{2})(?<assignment>=?)\z/ =~ method_name

    translated_attr_name = attribute.to_sym
    return unless translated_attribute_names.include?(translated_attr_name)

    locale = locale.to_sym
    assigning = assignment.present?

    [translated_attr_name, locale, assigning]
  end

  def toggle_fallback(enabled)
    if block_given?
      old_value = @enabled_fallback
      begin
        @enabled_fallback = enabled
        yield
      ensure
        @enabled_fallback = old_value
      end
    else
      @enabled_fallback = enabled
    end
  end
end
