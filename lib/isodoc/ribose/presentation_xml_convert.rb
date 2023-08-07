require_relative "init"
require "isodoc"
require "metanorma-generic"

module IsoDoc
  module Ribose
    class PresentationXMLConvert < IsoDoc::Generic::PresentationXMLConvert
      def annex1(elem)
        lbl = @xrefs.anchor(elem["id"], :label)
        prefix_name(elem, "<br/><br/>", lbl, "title")
      end

      def middle_title(docxml); end

      def termsource1(elem)
        mod = elem.at(ns("./modification")) and
          termsource_modification(mod)
        elem.children = l10n("<strong>#{@i18n.source}:</strong> " \
                             "#{to_xml(elem.children).strip}")
        elem&.next_element&.name == "termsource" and elem.next = "; "
      end

      def preface_rearrange(doc)
        preface_move(doc.at(ns("//preface/abstract")),
                     %w(foreword executivesummary introduction clause acknowledgements), doc)
        preface_move(doc.at(ns("//preface/foreword")),
                     %w(executivesummary introduction clause acknowledgements), doc)
        preface_move(doc.at(ns("//preface/executivesummary")),
                     %w(introduction clause acknowledgements), doc)
        preface_move(doc.at(ns("//preface/introduction")),
                     %w(clause acknowledgements), doc)
        preface_move(doc.at(ns("//preface/acknowledgements")),
                     %w(), doc)
      end

      include Init
    end
  end
end
