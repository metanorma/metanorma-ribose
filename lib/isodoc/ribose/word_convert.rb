require "isodoc"
require "isodoc/generic/word_convert"
require "isodoc/ribose/metadata"
require_relative "init"

module IsoDoc
  module Ribose
    # A {Converter} implementation that generates Word output, and a document
    # schema encapsulation of the document for validation
    class WordConvert < IsoDoc::Generic::WordConvert
      def configuration
        Metanorma::Ribose.configuration
      end

      include BaseConvert
      include Init
    end
  end
end
