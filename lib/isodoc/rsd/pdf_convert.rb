require "isodoc"
require "isodoc/rsd/metadata"

module IsoDoc
  module Rsd
    # A {Converter} implementation that generates PDF HTML output, and a
    # document schema encapsulation of the document for validation
    class PdfConvert <  IsoDoc::XslfoPdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def pdf_stylesheet(docxml)
        "rsd.standard.xsl"
      end
    end
  end
end

