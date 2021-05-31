module IsoDoc
  module Ribose
    module BaseConvert
      def executivesummary(docxml, out)
        f = docxml.at(ns("//executivesummary")) || return
        title_attr = { class: "IntroTitle" }
        page_break(out)
        out.div **{ class: "Section3", id: f["id"] } do |div|
          clause_name(nil, f&.at(ns("./title")), div, title_attr)
          f.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def is_clause?(name)
        return true if name == "executivesummary"

        super
      end

      def clausedelim
        ""
      end
    end
  end
end
