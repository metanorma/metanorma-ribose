# frozen_string_literal: true

require "metanorma/html"

module Metanorma
  module Ribose
    # HTML format adapter slice for the Ribose flavor: binds the flavor's
    # document root to the standard document rendering.
    module Html
      class Renderer < Metanorma::Html::StandardRenderer
        register_render "Metanorma::Ribose::Document::Root", :render_standard_document

        # The ribose titlepage: agency docs (security/recipient-bearing)
        # get the docinfo-table layout, publisher docs the title/docid band.
        def render_coverpage(doc)
          bibdata = doc.bibdata
          return "" unless bibdata

          render_liquid("_ribose_cover.html.liquid", {
                          "cover" => bibdata,
                          "title" => cover_title_text(bibdata),
                        })
        end

        private

        def cover_title_text(bibdata)
          title = bibdata.title_for("en") ||
                  (bibdata.title if bibdata.respond_to?(:title))
          return nil unless title

          if title.is_a?(Metanorma::Iso::Document::Metadata::AbstractTitle) &&
              title.value
            title.value.to_s
          else
            title.to_s
          end
        end
      end
    end
  end
end
