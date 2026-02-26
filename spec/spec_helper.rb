require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "asciidoctor"
require "metanorma-ribose"
require "isodoc/ribose/html_convert"
require "isodoc/ribose/word_convert"
require "metanorma/standoc/converter"
require "rspec/matchers"
require "equivalent-xml"
require "htmlentities"
require "metanorma"
require "metanorma/ribose"
require "canon"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around do |example|
    Dir.mktmpdir("rspec-") do |dir|
      Dir.chdir(dir) { example.run }
    end
  end
end

OPTIONS = [backend: :ribose, header_footer: true].freeze

def metadata(hash)
  hash.sort.to_h
    .delete_if { |_, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
end

def presxml_options
  { semanticxmlinsert: "false" }
end

def strip_guid(str)
  str.gsub(%r{ id="_[^"]+"}, ' id="_"')
    .gsub(%r{ semx-id="[^"]*"}, '')
    .gsub(%r{ target="_[^"]+"}, ' target="_"')
    .gsub(%r{ source="_[^"]+"}, ' source="_"')
    .gsub(%r{<fetched>[^<]+</fetched>}, "<fetched/>")
    .gsub(%r{ schema-version="[^"]+"}, "")
end

def htmlencode(html)
  HTMLEntities.new.encode(html, :hexadecimal).gsub(/&#x3e;/, ">")
    .gsub(/&#xa;/, "\n").gsub(/&#x22;/, '"')
    .gsub(/&#x3c;/, "<").gsub(/&#x26;/, "&").gsub(/&#x27;/, "'")
    .gsub(/\\u(....)/) { "&#x#{$1.downcase};" }
end

ASCIIDOC_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:

HDR

VALIDATING_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:

HDR

BOILERPLATE_XML = File.join(File.dirname(__FILE__), "..",
                            "lib", "metanorma", "ribose", "boilerplate.adoc")

def boilerplate_read(file, xmldoc)
  conv = Metanorma::Ribose::Converter.new(:ribose, {})
  conv.init(Asciidoctor::Document.new([]))
  cl = Metanorma::Ribose::Cleanup.new(conv)
  x = cl.boilerplate_isodoc(xmldoc).populate_template(file, nil)
  ret = cl.boilerplate_file_restructure(x)
  ret.to_xml(encoding: "UTF-8", indent: 2,
             save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
    .gsub(/<(\/)?sections>/, "<\\1boilerplate>")
    .gsub(/ id="_[^"]+"/, " id='_'")
    .gsub(/<ol>/, "<ol id='_' type='alphabet'>")
end

def boilerplate(xmldoc)
  file = File.read(BOILERPLATE_XML, encoding: "utf-8")
  ret = Nokogiri::XML(boilerplate_read(file, xmldoc))
  ret.root.to_xml(encoding: "UTF-8", indent: 2,
                  save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
end

LICENSE_BOILERPLATE = <<~CONTENT.freeze
  <license-statement>
    <clause>
      <title>Warning for Drafts</title>
      <p id='_'>
       This document is not a Ribose Standard. It is distributed for review
       and comment, and is subject to change without notice and may not be
       referred to as a Standard. Recipients of this draft are invited to
       submit, with their comments, notification of any relevant patent
       rights of which they are aware and to provide supporting
       documentation.
      </p>
    </clause>
  </license-statement>
CONTENT

BLANK_HDR = <<~"HDR".freeze
  <?xml version="1.0" encoding="UTF-8"?>
  <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Ribose::VERSION}" flavor="ribose">
    <bibdata type="standard">
     <title language="en" type="main">Document title</title>
      <contributor>
        <role type="author"/>
        <organization>
            <name>Ribose Asia Limited</name>
            <abbreviation>Ribose</abbreviation>
        </organization>
      </contributor>
      <contributor>
        <role type="publisher"/>
        <organization>
            <name>Ribose Asia Limited</name>
            <abbreviation>Ribose</abbreviation>
        </organization>
      </contributor>
      <language>en</language>
      <script>Latn</script>

      <status> <stage>published</stage> </status>

      <copyright>
        <from>#{Time.new.year}</from>
        <owner>
          <organization>
            <name>Ribose Asia Limited</name>
            <abbreviation>Ribose</abbreviation>
          </organization>
        </owner>
      </copyright>
      <ext>
      <doctype>standard</doctype>
      <flavor>ribose</flavor>
      </ext>
    </bibdata>
                        <metanorma-extension>
      <semantic-metadata>
         <stage-published>true</stage-published>
      </semantic-metadata>
           <presentation-metadata>
                    <toc-heading-levels>2</toc-heading-levels>
         <html-toc-heading-levels>2</html-toc-heading-levels>
         <doc-toc-heading-levels>2</doc-toc-heading-levels>
         <pdf-toc-heading-levels>2</pdf-toc-heading-levels>
           </presentation-metadata>
         </metanorma-extension>
HDR

def blank_hdr_gen
  <<~"HDR"
    #{BLANK_HDR}
    #{boilerplate(Nokogiri::XML("#{BLANK_HDR}</ribose-standard>"))}
  HDR
end

HTML_HDR = <<~HDR.freeze
  <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
    <div class="title-section">
      <p>&#160;</p>
    </div>
    <br/>
    <div class="prefatory-section">
      <p>&#160;</p>
    </div>
    <br/>
    <div class="main-section">
HDR

def mock_pdf
  allow(Mn2pdf).to receive(:convert) do |url, output,|
    FileUtils.cp(url.gsub(/"/, ""), output.gsub(/"/, ""))
  end
end
