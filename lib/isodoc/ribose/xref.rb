require "metanorma-generic"

module IsoDoc
  module Ribose
    class Counter < IsoDoc::XrefGen::Counter
    end

    class Xref < IsoDoc::Generic::Xref
      def annex_name_lbl(clause, num)
        obl = l10n("(#{@labels['inform_annex']})")
        clause["obligation"] == "normative" and
          obl = l10n("(#{@labels['norm_annex']})")
        l10n("#{@labels['annex']} #{num}<br/>#{obl}")
      end

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

      def section_names1(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, level: level, xref: num }
        # subclauses are not prefixed with "Clause"
        i = Counter.new(0, prefix: "#{num}.")
        clause.xpath(ns("./clause | ./terms | ./term | ./definitions | " \
                        "./references")).each do |c|
          section_names1(c, i.increment(c).print, level + 1)
        end
      end

      # we can reference 0-number clauses in introduction
      def introduction_names(clause)
        clause.nil? and return
        clause.at(ns("./clause")) and
          @anchors[clause["id"]] = { label: "0", level: 1, type: "clause",
                                     xref: clause.at(ns("./title"))&.text }
        i = Counter.new(0, prefix: "0.")
        clause.xpath(ns("./clause")).each do |c|
          section_names1(c, i.increment(c).print, 2)
        end
      end
    end
  end
end
