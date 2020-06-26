require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/ribose/converter"
require_relative "isodoc/ribose/base_convert"
require_relative "isodoc/ribose/html_convert"
require_relative "isodoc/ribose/word_convert"
require_relative "isodoc/ribose/pdf_convert"
require_relative "isodoc/ribose/presentation_xml_convert"
require_relative "isodoc/ribose/xref"
require_relative "metanorma/ribose/version"

if defined? Metanorma
  require_relative "metanorma/ribose"
  Metanorma::Registry.instance.register(Metanorma::Ribose::Processor)
end
