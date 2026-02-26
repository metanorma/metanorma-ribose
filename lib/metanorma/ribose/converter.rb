require "metanorma-standoc"
require "metanorma-generic"

module Metanorma
  module Ribose
    class Converter < Metanorma::Generic::Converter
      register_for "ribose"

      def sectiontype(node, level = true)
        ret = sectiontype1(node)
        ret1 = sectiontype_streamline(ret)
        return ret1 if ret1 == "symbols and abbreviated terms"
        return ret1 if ret1 == "executive summary"
        return nil unless !level || node.level == 1
        return nil if @seen_headers.include? ret

        @seen_headers << ret
        ret1
      end

      def make_preface(xml, sect)
        if xml.at("//foreword | //introduction | //acknowledgements | "\
                  "//clause[@preface] | //executivesummary")
          preface = sect.add_previous_sibling("<preface/>").first
          f = xml.at("//foreword") and preface.add_child f.remove
          f = xml.at("//executivesummary") and preface.add_child f.remove
          f = xml.at("//introduction") and preface.add_child f.remove
          move_clauses_into_preface(xml, preface)
          f = xml.at("//acknowledgements") and preface.add_child f.remove
        end
        make_abstract(xml, sect)
      end

      def configuration
        Metanorma::Ribose.configuration
      end

      def presentation_xml_converter(node)
        IsoDoc::Ribose::PresentationXMLConvert
          .new(html_extract_attributes(node)
          .merge(output_formats: ::Metanorma::Ribose::Processor.new.output_formats))
      end

      def html_converter(node)
        IsoDoc::Ribose::HtmlConvert.new(html_extract_attributes(node))
      end

      def pdf_converter(node)
        node.attr("no-pdf") and return nil
        IsoDoc::Ribose::PdfConvert.new(pdf_extract_attributes(node))
      end

      def doc_converter(node)
        IsoDoc::Ribose::WordConvert.new(doc_extract_attributes(node))
      end
    end
  end
end

require_relative "log"
