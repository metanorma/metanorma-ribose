require "metanorma-generic"

module IsoDoc
  module Rsd
    class Xref < IsoDoc::Generic::Xref
      def annex_name_lbl(clause, num)
        obl = l10n("(#{@labels['inform_annex']})")
        obl = l10n("(#{@labels['norm_annex']})") if clause["obligation"] == "normative"
        l10n("#{@labels['annex']} #{num}<br/>#{obl}")
      end

      def initial_anchor_names(d)
        preface_names(d.at(ns("//executivesummary")))
        super
        sequential_asset_names(
          d.xpath(ns("//preface/abstract | //foreword | //introduction | "\
                     "//preface/clause | //acknowledgements | //executivesummary")))
      end

      def section_names1(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, level: level, xref: num }
        # subclauses are not prefixed with "Clause"
        clause.xpath(ns("./clause | ./terms | ./term | ./definitions | ./references")).
          each_with_index do |c, i|
          section_names1(c, "#{num}.#{i + 1}", level + 1)
        end
      end
    end
  end
end
