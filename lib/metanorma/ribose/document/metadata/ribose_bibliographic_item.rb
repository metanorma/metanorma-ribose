# frozen_string_literal: true

module Metanorma
  module Ribose::Document
    module Metadata
      # Bibliographical description of a Ribose document.
      # Inherits all ISO bibliographic fields; overrides ext for Ribose format.
      class RiboseBibliographicItem < Metanorma::Iso::Document::Metadata::IsoBibliographicItem
        attribute :ext, RiboseBibDataExtensionType

        xml do
          element "bibdata"
          map_element "ext", to: :ext
        end

        # --- Ribose cover facts (isodoc ribose titlepage parity) --------

        def cover_stage_display
          s = Array(status&.stage).first
          return nil unless s

          text = element_text(s)
          text.empty? ? nil : text.capitalize
        end

        # The en doctype carries the display label ("Application Note",
        # "Best Practice Guide"); bare values ("report") are capitalized.
        def cover_doctype_label
          d = Array(ext&.doctype).find { |x| safe_attr_language(x) == "en" } ||
              Array(ext&.doctype).first
          return nil unless d

          v = d.value.to_s
          return nil if v.empty?

          v == v.downcase ? v.capitalize : v
        end

        def cover_primary_docidentifier
          (doc_identifier.find(&:primary) || doc_identifier.first)&.value
        end

        def cover_publisher_name
          org_name_for_role("publisher")
        end

        def cover_committee_name
          subdivision_text_for("committee", :name)
        end

        def cover_copyright_year
          from = Array(copyright).first&.from
          return nil unless from

          year = element_text(from)
          year.empty? ? nil : year
        end

        def cover_copyright_owner
          owner = Array(Array(copyright).first&.owner).first
          return nil unless owner

          name = Array(owner.organization&.name).first
          content = name&.content
          content.to_s.empty? ? nil : content
        end

        def cover_security
          s = ext&.security
          s.to_s.empty? ? nil : s
        end

        def cover_recipient
          r = ext&.recipient
          r.to_s.empty? ? nil : r
        end

        liquid do
          map "cover_stage_display", to: :cover_stage_display
          map "cover_doctype_label", to: :cover_doctype_label
          map "cover_primary_docidentifier", to: :cover_primary_docidentifier
          map "cover_publisher_name", to: :cover_publisher_name
          map "cover_committee_name", to: :cover_committee_name
          map "cover_copyright_year", to: :cover_copyright_year
          map "cover_copyright_owner", to: :cover_copyright_owner
          map "cover_security", to: :cover_security
          map "cover_recipient", to: :cover_recipient
        end

        private

        def element_text(el)
          content = el.respond_to?(:content) ? el.content : el
          content = el.text if content.to_s.empty? && el.respond_to?(:text)
          Array(content).join.to_s
        end

        def safe_attr_language(el)
          el.language if el.respond_to?(:language)
        end

        def org_name_for_role(role_type)
          Array(contributor).each do |c|
            next unless Array(c.role).any? { |r| r.type == role_type }

            name = Array(c.organization&.name).first
            content = name&.content
            return content unless content.to_s.empty?
          end
          nil
        end
      end
    end
  end
end
