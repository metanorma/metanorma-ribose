require_relative "init"
require "isodoc"
require "metanorma-generic"

module IsoDoc
  module Ribose
    class PresentationXMLConvert < IsoDoc::Generic::PresentationXMLConvert
      # KILL
      def annex1x(elem)
        lbl = @xrefs.anchor(elem["id"], :label)
        prefix_name(elem, "<br/><br/>", lbl, "title")
      end

      def annex_delim(_elem)
        "<br/><br/>"
      end

      def middle_title(docxml); end

      # KILL
      def termsource1xx(elem)
        elem.children = l10n("<strong>#{@i18n.source}:</strong> " \
                             "#{to_xml(elem.children).strip}")
        elem&.next_element&.name == "termsource" and elem.next = "; "
      end

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

       def clause(docxml)
         super
         docxml.xpath(ns("//executivesummary | //appendix")).each { |x| clause1(x) }
       end

      include Init
    end
  end
end
