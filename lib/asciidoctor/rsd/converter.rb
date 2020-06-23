require "asciidoctor/standoc/converter"
require 'asciidoctor/generic/converter'

module Asciidoctor
  module Rsd
    # A {Converter} implementation that generates RSD output, and a document
    # schema encapsulation of the document for validation
    #
    class Converter < Asciidoctor::Generic::Converter
      XML_ROOT_TAG = 'rsd-standard'.freeze
      XML_NAMESPACE = 'https://www.metanorma.org/ns/rsd'.freeze

      register_for "rsd"

      def sectiontype(node, level = true)
        ret = node&.attr("heading")&.downcase ||
          node.title.gsub(/<[^>]+>/, "").downcase
        ret1 = sectiontype_streamline(ret)
        return ret1 if "symbols and abbreviated terms" == ret1
        return ret1 if "executive summary" == ret1
        return nil unless !level || node.level == 1
        return nil if @seen_headers.include? ret
        @seen_headers << ret
        ret1
      end

      def make_preface(x, s)
        if x.at("//foreword | //introduction | //acknowledgements | "\
            "//clause[@preface] | //executivesummary")
          preface = s.add_previous_sibling("<preface/>").first
          f = x.at("//foreword") and preface.add_child f.remove
          f = x.at("//executivesummary") and preface.add_child f.remove
          f = x.at("//introduction") and preface.add_child f.remove
          move_clauses_into_preface(x, preface)
          f = x.at("//acknowledgements") and preface.add_child f.remove
        end
        make_abstract(x, s)
      end

      def clause_parse(attrs, xml, node)
        sectiontype(node) == "executive summary" and
          return executivesummary_parse(attrs, xml, node)
        super
      end

      def executivesummary_parse(attrs, xml, node)
        xml.executivesummary **attr_code(attrs) do |xml_section|
          xml_section.title { |t| t << node.title || "Executive Summary" }
          content = node.content
          xml_section << content
        end
      end

      def configuration
        Metanorma::Rsd.configuration
      end

      def presentation_xml_converter(node)
        IsoDoc::Rsd::PresentationXMLConvert.new(html_extract_attributes(node))
      end

      def html_converter(node)
        IsoDoc::Rsd::HtmlConvert.new(html_extract_attributes(node))
      end

      def pdf_converter(node)
        return nil if node.attr("no-pdf")
        IsoDoc::Rsd::PdfConvert.new(html_extract_attributes(node))
      end

      def doc_converter(node)
        IsoDoc::Rsd::WordConvert.new(doc_extract_attributes(node))
      end
    end
  end
end
