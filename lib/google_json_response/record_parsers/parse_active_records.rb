require 'active_record'
require 'active_model'
require 'google_json_response/record_parsers/parser_base'

module GoogleJsonResponse
  module RecordParsers
    class ParseActiveRecords < ParserBase
      def call
        if serializable_resource.is_a?(Hash)
          @parsed_data = {
            data: serializable_resource
          }
        else
          data = {
            sort: sort,
            item_per_page: options[:item_per_page]&.to_i,
            page_index: options[:page_index]&.to_i || record.try(:current_page),
            total_pages: options[:total_pages]&.to_i || record.try(:total_pages),
            total_items: options[:total_items]&.to_i || record.try(:total_count),
            items: serializable_resource
          }.reverse_merge(options).compact
          @parsed_data = { data: data }
        end
      end

      private

      def serializable_resource
        @serializable_resource ||=
          record.is_a?(ActiveRecord::Relation) ? serializable_collection_resource : super
      end
    end
  end
end
