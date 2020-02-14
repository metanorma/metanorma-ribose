require "isodoc"
require "isodoc/acme/html_convert"
require "isodoc/rsd/metadata"

module IsoDoc
  module Rsd
    # A {Converter} implementation that generates HTML output, and a document
    # schema encapsulation of the document for validation
    #
    class HtmlConvert < IsoDoc::Acme::HtmlConvert
      def configuration
        Metanorma::Rsd.configuration
      end

      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def info(isoxml, out)
        @meta.security isoxml, out
        super
      end
    end
  end
end

