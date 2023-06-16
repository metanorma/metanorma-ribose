require "metanorma/processor"

module Metanorma
  module Ribose
    class Processor < Metanorma::Generic::Processor
      def configuration
        Metanorma::Ribose.configuration
      end

      def output_formats
        super.merge(
          html: "html",
          doc: "doc",
          pdf: "pdf",
        )
      end

      def fonts_manifest
        {
          "Source Sans Pro" => nil,
          "STIX Two Math" => nil,
          "Source Serif Pro" => nil,
          "Source Code Pro" => nil,
          "Open Sans" => nil,
          "Noto Sans" => nil,
          "Noto Sans HK" => nil,
          "Noto Sans JP" => nil,
          "Noto Sans KR" => nil,
          "Noto Sans SC" => nil,
          "Noto Sans TC" => nil,
          "Noto Sans Mono" => nil,
          "Noto Sans Mono CJK HK" => nil,
          "Noto Sans Mono CJK JP" => nil,
          "Noto Sans Mono CJK KR" => nil,
          "Noto Sans Mono CJK SC" => nil,
          "Noto Sans Mono CJK TC" => nil,
        }
      end

      def version
        "Metanorma::Ribose #{Metanorma::Ribose::VERSION}"
      end

      def output(isodoc_node, inname, outname, format, options = {})
        case format
        when :html
          IsoDoc::Ribose::HtmlConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :doc
          IsoDoc::Ribose::WordConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :pdf
          IsoDoc::Ribose::PdfConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :presentation
          IsoDoc::Ribose::PresentationXMLConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end
    end
  end
end
