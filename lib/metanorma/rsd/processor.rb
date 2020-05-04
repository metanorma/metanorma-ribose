require "metanorma/processor"

module Metanorma
  module Rsd
    def self.fonts_used
      ["SourceSansPro-Light", "SourceSerifPro", "SourceCodePro-Light", "HanSans"]
    end

    class Processor < Metanorma::Processor

      def initialize
        @short = :rsd
        @input_format = :asciidoc
        @asciidoctor_backend = :rsd
      end

      def output_formats
        super.merge(
          html: "html",
          doc: "doc",
          pdf: "pdf"
        )
      end

      def version
        "Metanorma::Rsd #{Metanorma::Rsd::VERSION}"
      end

      def input_to_isodoc(file, filename)
        Metanorma::Input::Asciidoc.new.process(file, filename, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Rsd::HtmlConvert.new(options).convert(outname, isodoc_node)
        when :doc
          IsoDoc::Rsd::WordConvert.new(options).convert(outname, isodoc_node)
        when :pdf
          IsoDoc::Rsd::PdfConvert.new(options).convert(outname, isodoc_node)
        else
          super
        end
      end
    end
  end
end
