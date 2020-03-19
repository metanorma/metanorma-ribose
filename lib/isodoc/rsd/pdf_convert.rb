require "isodoc"
require "isodoc/acme/pdf_convert"
require "isodoc/rsd/metadata"

module IsoDoc
  module Rsd
    # A {Converter} implementation that generates PDF HTML output, and a
    # document schema encapsulation of the document for validation
    class PdfConvert < IsoDoc::Acme::PdfConvert
      def configuration
        Metanorma::Rsd.configuration
      end

      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def info(isoxml, out)
        @meta.security isoxml, out
        @meta.recipient isoxml, out
        super
      end

      def annex_name(annex, name, div)
        div.h1 **{ class: "Annex" } do |t|
          t << "#{anchor(annex['id'], :label)}<br/><br/>"
          name&.children&.each { |c2| parse(c2, t) }
        end
      end

            def annex_name_lbl(clause, num)
      obl = l10n("(#{@inform_annex_lbl})")
      obl = l10n("(#{@norm_annex_lbl})") if clause["obligation"] == "normative"
      l10n("#{@annex_lbl} #{num}<br/>#{obl}")
    end
    end
  end
end

