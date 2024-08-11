require "isodoc"
require_relative "base_convert"

module IsoDoc
  module Ribose
    # A {Converter} implementation that generates PDF HTML output, and a
    # document schema encapsulation of the document for validation
    class PdfConvert < IsoDoc::Generic::PdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      include BaseConvert
      include Init
    end
  end
end
