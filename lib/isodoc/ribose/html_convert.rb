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

      def make_body3(body, docxml)
        body.div class: "main-section" do |div3|
          boilerplate docxml, div3
          front docxml, div3
          middle docxml, div3
          footnotes div3
          comments div3
        end
      end

      include BaseConvert
      include Init
    end
  end
end
