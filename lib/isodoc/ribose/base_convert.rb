module IsoDoc
  module Ribose
    module BaseConvert
      def executivesummary(clause, out)
        title_attr = { class: "IntroTitle" }
        page_break(out)
        out.div class: "Section3", id: clause["id"] do |div|
          clause_name(clause, clause&.at(ns("./title")), div, title_attr)
          clause.elements.each do |e|
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
