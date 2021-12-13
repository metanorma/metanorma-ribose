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

      def termsource1(elem)
        mod = elem.at(ns("./modification")) and
          termsource_modification(mod)
        elem.children = l10n("<strong>#{@i18n.source}:</strong> "\
                             "#{elem.children.to_xml.strip}")
        elem&.next_element&.name == "termsource" and elem.next = "; "
      end

      include Init
    end
  end
end
