# frozen_string_literal: true

module Services
  module MachineTranslations
    # This translator service recieves the field value
    # and the locale of the field which has to be
    # translated. It returns the appended value for both.
    # Based on Decidim's Decidim::Dev::DummyTranslator class
    class TranslatorService
      attr_reader :text, :source_locale, :target_locale, :resource, :field_name

      def initialize(resource, field_name, text, target_locale, source_locale)
        @resource = resource
        @field_name = field_name
        @text = text
        @target_locale = target_locale
        @source_locale = source_locale
      end

      def translate
        translated_text = "#{target_locale} - #{text}"

        Decidim::MachineTranslationSaveJob.perform_later(
          resource,
          field_name,
          target_locale,
          translated_text
        )
      end
    end
  end
end