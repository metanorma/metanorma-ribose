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

      def recipient(isoxml, _out)
        recipient = isoxml.at(ns("//bibdata/ext/recipient")) || return
        set(:recipient, recipient.text)
      end

      def version(isoxml, _out)
        super
        revdate = get[:revdate]
        set(:revdate_MMMddyyyy, MMMddyyyy(revdate))
      end

      def MMMddyyyy(isodate)
        return nil if isodate.nil?
        arr = isodate.split("-")
        date = if arr.size == 1 and (/^\d+$/.match isodate)
                 Date.new(*arr.map(&:to_i)).strftime("%Y")
               elsif arr.size == 2
                 Date.new(*arr.map(&:to_i)).strftime("%B %Y")
               else
                 Date.parse(isodate).strftime("%B %d, %Y")
               end
      end
    end
  end
end
