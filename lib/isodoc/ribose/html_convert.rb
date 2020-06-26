require "isodoc"
require "isodoc/generic/html_convert"
require "isodoc/ribose/metadata"

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
      body.div **{ class: "main-section" } do |div3|
        boilerplate docxml, div3
        abstract docxml, div3
        foreword docxml, div3
        executivesummary docxml, div3
        introduction docxml, div3
        preface docxml, div3
        acknowledgements docxml, div3
        middle docxml, div3
        footnotes div3
        comments div3
      end
    end

      include BaseConvert
    end
  end
end

