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

      include Init
    end
  end
end
