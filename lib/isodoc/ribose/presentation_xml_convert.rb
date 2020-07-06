require_relative "init"
require "isodoc"
require "metanorma-generic"

module IsoDoc
  module Ribose
    class PresentationXMLConvert < IsoDoc::Generic::PresentationXMLConvert
      def annex1(f)
        lbl = @xrefs.anchor(f['id'], :label)
        prefix_name(f, "<br/><br/>", lbl, "title")
      end

      include Init
    end
  end
end

