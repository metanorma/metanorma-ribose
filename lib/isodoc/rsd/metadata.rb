require "isodoc"

module IsoDoc
  module Rsd

    class Metadata < IsoDoc::Acme::Metadata
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
        set(:revdate_monthyear, monthyr(revdate))
        set(:revdate_MMMddyyyy, MMMddyyyy(revdate))
      end

      MONTHS = {
        "01": "January",
        "02": "February",
        "03": "March",
        "04": "April",
        "05": "May",
        "06": "June",
        "07": "July",
        "08": "August",
        "09": "September",
        "10": "October",
        "11": "November",
        "12": "December",
      }.freeze

      def monthyr(isodate)
        m = /(?<yr>\d\d\d\d)-(?<mo>\d\d)/.match isodate
        return isodate unless m && m[:yr] && m[:mo]
        return "#{MONTHS[m[:mo].to_sym]} #{m[:yr]}"
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
