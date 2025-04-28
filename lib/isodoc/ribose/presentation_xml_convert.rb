require_relative "init"
require "isodoc"
require "metanorma-generic"

module IsoDoc
  module Ribose
    class PresentationXMLConvert < IsoDoc::Generic::PresentationXMLConvert
      def annex_delim(_elem)
        "<br/><br/>"
      end

      def middle_title(docxml); end

      def termsource_label(elem, sources)
        elem.replace(l10n("<strong>#{@i18n.source}</strong>: #{sources}"))
      end

      def designation_boldface(desgn); end

      def preface_rearrange(doc)
        preface_move(doc.xpath(ns("//preface/abstract")),
                     %w(foreword executivesummary introduction clause acknowledgements), doc)
        preface_move(doc.xpath(ns("//preface/foreword")),
                     %w(executivesummary introduction clause acknowledgements), doc)
        preface_move(doc.xpath(ns("//preface/executivesummary")),
                     %w(introduction clause acknowledgements), doc)
        preface_move(doc.xpath(ns("//preface/introduction")),
                     %w(clause acknowledgements), doc)
        preface_move(doc.xpath(ns("//preface/acknowledgements")),
                     %w(), doc)
      end

      # KILL 
      def clausex(docxml)
        super
        docxml.xpath(ns("//appendix")).each do |x|
          clause1(x)
        end
      end

      def ul_label_list(_elem)
        %w(&#x6f; &#x2014; &#x2022;)
      end

      def ol_label_template(_elem)
        super
          .merge({
                   alphabet: %{%<span class="fmt-label-delim">.</span>},
                   arabic: %{%<span class="fmt-label-delim">.</span>},
                   roman: %{%<span class="fmt-label-delim">.</span>},
                 })
      end

      include Init
    end
  end
end
