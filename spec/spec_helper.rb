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

def metadata(hash)
  hash.sort.to_h
    .delete_if { |_, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
end

def strip_guid(str)
  str.gsub(%r{ id="_[^"]+"}, ' id="_"')
    .gsub(%r{ target="_[^"]+"}, ' target="_"')
end

def htmlencode(html)
  HTMLEntities.new.encode(html, :hexadecimal).gsub(/&#x3e;/, ">")
    .gsub(/&#xa;/, "\n").gsub(/&#x22;/, '"')
    .gsub(/&#x3c;/, "<").gsub(/&#x26;/, "&").gsub(/&#x27;/, "'")
    .gsub(/\\u(....)/) { "&#x#{$1.downcase};" }
end

def xmlpp(xml)
  c = HTMLEntities.new
  xml &&= xml.split(/(&\S+?;)/).map do |n|
    if /^&\S+?;$/.match?(n)
      c.encode(c.decode(n), :hexadecimal)
    else n
    end
  end.join
  xsl = <<~XSL
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
      <xsl:strip-space elements="*"/>
      <xsl:template match="/">
        <xsl:copy-of select="."/>
      </xsl:template>
    </xsl:stylesheet>
  XSL
  Nokogiri::XSLT(xsl).transform(Nokogiri::XML(xml, &:noblanks))
    .to_xml(indent: 2, encoding: "UTF-8")
    .gsub(%r{<fetched>[^<]+</fetched>}, "<fetched/>")
    .gsub(%r{ schema-version="[^"]+"}, "")
end

ASCIIDOC_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:

HDR

VALIDATING_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:

HDR

BOILERPLATE_XML = File.join(File.dirname(__FILE__), "..",
                            "lib", "metanorma", "ribose", "boilerplate.xml")

def boilerplate(xmldoc)
  file = File.read(BOILERPLATE_XML, encoding: "utf-8")
  conv = Metanorma::Ribose::Converter
    .new(nil, backend: :ribose, header_footer: true)
  conv.init(Asciidoctor::Document.new([]))
  ret = Nokogiri::XML(
    conv.boilerplate_isodoc(xmldoc).populate_template(file, nil)
    .gsub(/<p>/, "<p id='_'>")
    .gsub(/<ol>/, "<ol id='_' type='alphabet'>"),
  )
  conv.smartquotes_cleanup(ret)
  HTMLEntities.new.decode(ret.to_xml)
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
  <rsd-standard xmlns="https://www.metanorma.org/ns/rsd" type="semantic" version="#{Metanorma::Ribose::VERSION}">
    <bibdata type="standard">
     <title language="en" format="text/plain">Document title</title>
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
      </ext>
    </bibdata>
HDR

def blank_hdr_gen
  <<~"HDR"
    #{BLANK_HDR}
    #{boilerplate(Nokogiri::XML("#{BLANK_HDR}</ribose-standard>"))}
  HDR
end

HTML_HDR = <<~"HDR".freeze
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
  allow(::Mn2pdf).to receive(:convert) do |url, output,|
    FileUtils.cp(url.gsub(/"/, ""), output.gsub(/"/, ""))
  end
end
