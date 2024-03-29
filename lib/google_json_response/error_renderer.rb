require "google_json_response/error_parsers/parse_generic_error"
require "google_json_response/error_parsers/parse_standard_error"

module GoogleJsonResponse
  class ErrorRenderer
    attr_reader :errors, :options, :rendered_content


    def initialize(errors, options = {})
      @errors = errors
      @options = options
    end

    def call
      parser.call
      @rendered_content = parser.parsed_data
    end

    private

    attr_reader :errors

    def parser
      @parser ||=
        if standard_error?
          GoogleJsonResponse::ErrorParsers::ParseStandardError.new(errors)
        elsif active_model_error?
          GoogleJsonResponse::ErrorParsers::ParseActiveRecordError.new(errors, options)
        else
          GoogleJsonResponse::ErrorParsers::ParseGenericError.new(errors)
        end
    end

    def standard_error?
      return true if errors.is_a?(StandardError)
      false
    end

    def active_model_error?
      return false unless defined?(::ActiveModel::Errors)
      errors.is_a?(::ActiveModel::Errors)
    end

    def generic_error?
      errors.is_a?(::String) || errors.is_a?(::Array)
    end
  end
end
