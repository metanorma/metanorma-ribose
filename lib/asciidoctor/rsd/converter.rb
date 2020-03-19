require "asciidoctor/standoc/converter"
require 'asciidoctor/acme/converter'

module Asciidoctor
  module Rsd
    # A {Converter} implementation that generates RSD output, and a document
    # schema encapsulation of the document for validation
    #
    class Converter < Asciidoctor::Acme::Converter
      register_for "rsd"

      def metadata_recipient(node, xml)
        recipient = node.attr("recipient") || return
        xml.recipient recipient
      end

      def metadata_security(node, xml)
        security = node.attr("security") || return
        xml.security security
      end

      def metadata_ext(node, xml)
        super
        metadata_security(node, xml)
        metadata_recipient(node, xml)
      end

      def configuration
        Metanorma::Rsd.configuration
      end

      def html_converter(node)
        IsoDoc::Rsd::HtmlConvert.new(html_extract_attributes(node))
      end

      def pdf_converter(node)
        IsoDoc::Rsd::PdfConvert.new(html_extract_attributes(node))
      end

      def word_converter(node)
        IsoDoc::Rsd::WordConvert.new(doc_extract_attributes(node))
      end
    end
  end
end
