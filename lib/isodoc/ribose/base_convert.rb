module IsoDoc
  module Ribose
    module BaseConvert
      def annex_name(annex, name, div)
        div.h1 **{ class: "Annex" } do |t|
          t << "#{@xrefs.anchor(annex['id'], :label)}<br/><br/>"
          name&.children&.each { |c2| parse(c2, t) }
        end
      end

      def executivesummary docxml, out
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

      def clausedelim
        ""
      end
    end
  end
end
