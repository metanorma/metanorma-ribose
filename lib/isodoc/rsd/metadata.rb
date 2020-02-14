require "isodoc"

module IsoDoc
  module Rsd

    class Metadata < IsoDoc::Acme::Metadata
      def configuration
        Metanorma::Rsd.configuration
      end
    end
  end
end
