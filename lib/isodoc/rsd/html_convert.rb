require "isodoc"
require "isodoc/generic/html_convert"
require "isodoc/rsd/metadata"

module IsoDoc
  module Rsd
    # A {Converter} implementation that generates HTML output, and a document
    # schema encapsulation of the document for validation
    #
    class HtmlConvert < IsoDoc::Generic::HtmlConvert
      def configuration
        Metanorma::Rsd.configuration
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

       def googlefonts
        <<~HEAD.freeze
    <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,300i,600,600i&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Source+Code+Pro:ital,wght@0,300;0,600;1,300;1,600&display=swap" rel="stylesheet">
        HEAD
      end

      include BaseConvert
    end
  end
end

