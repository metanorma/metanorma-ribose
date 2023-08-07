require "isodoc"
require "isodoc/generic/html_convert"
require "isodoc/ribose/metadata"
require_relative "init"

module IsoDoc
  module Ribose
    # A {Converter} implementation that generates HTML output, and a document
    # schema encapsulation of the document for validation
    #
    class HtmlConvert < IsoDoc::Generic::HtmlConvert
      def configuration
        Metanorma::Ribose.configuration
      end

      include BaseConvert
      include Init
    end
  end
end
