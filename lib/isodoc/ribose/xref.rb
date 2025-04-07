require "metanorma-generic"

module IsoDoc
  module Ribose
    class Counter < IsoDoc::XrefGen::Counter
    end

    class Xref < IsoDoc::Generic::Xref
      def initial_anchor_names(doc)
        super
        if blank?(@parse_settings) || @parse_settings[:clauses]
          introduction_names(doc.at(ns("//introduction")))
        end
        if blank?(@parse_settings)
          sequential_asset_names(
            doc.xpath(
              ns("//preface/abstract | //foreword | //introduction | " \
                 "//preface/clause | //acknowledgements | //executivesummary"),
            ),
          )
        end
      end

      # subclauses are not prefixed with "Clause"
      # retaining subtype for the semantics
      def section_name_anchors(clause, num, level)
        if clause["type"] == "section"
          xref = labelled_autonum(@labels["section"], num)
          label = labelled_autonum(@labels["section"], num)
          @anchors[clause["id"]] =
            { label:, xref:, elem: @labels["section"],
              title: clause_title(clause), level: level, type: "clause" }
        elsif level > 1
          #num = semx(clause, num)
          @anchors[clause["id"]] =
            { label: num, level: level, xref: num, subtype: "clause" }
        else super end
      end

      # we can reference 0-number clauses in introduction
      def introduction_names(clause)
        clause.nil? and return
        clause.at(ns("./clause")) and
          @anchors[clause["id"]] = { label: nil, level: 1, type: "clause",
                                     xref: clause.at(ns("./title"))&.text }
        i = Counter.new(0)
        clause.xpath(ns("./clause")).each do |c|
          section_names1(c, semx(clause, "0"), i.increment(c).print, 2)
        end
      end
    end
  end
end
