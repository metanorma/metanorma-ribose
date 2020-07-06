require "isodoc"

module IsoDoc
  module Ribose
    class Metadata < IsoDoc::Generic::Metadata
      def configuration
        Metanorma::Ribose.configuration
      end

      def version(isoxml, _out)
        super
        revdate = get[:revdate]
        set(:revdate_MMMddyyyy, MMMddyyyy(revdate))
      end
    end
  end
end
