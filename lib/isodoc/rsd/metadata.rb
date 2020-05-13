require "isodoc"

module IsoDoc
  module Rsd

    class Metadata < IsoDoc::Generic::Metadata
      def configuration
        Metanorma::Rsd.configuration
      end

      def version(isoxml, _out)
        super
        revdate = get[:revdate]
        set(:revdate_MMMddyyyy, MMMddyyyy(revdate))
      end
    end
  end
end
