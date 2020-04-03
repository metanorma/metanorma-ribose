require "isodoc"

module IsoDoc
  module Rsd

    class Metadata < IsoDoc::Generic::Metadata
      def configuration
        Metanorma::Rsd.configuration
      end

      def security(isoxml, _out)
        security = isoxml.at(ns("//bibdata/ext/security")) || return
        set(:security, security.text)
      end
    end
  end
end
