require "spec_helper"
require "metanorma"
require "fileutils"

RSpec.describe Metanorma::Ribose::Processor do
  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Ribose::Processor)

  let(:processor) { registry.find_processor(:ribose) }

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~OUTPUT
      [[:doc, "doc"], [:html, "html"], [:pdf, "pdf"], [:presentation, "presentation.xml"], [:rxl, "rxl"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::Ribose })
  end

  it "generates IsoDoc XML from a blank document" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
    INPUT

    output = Xml::C14n.format(strip_guid(<<~"OUTPUT"))
        #{blank_hdr_gen}
        <sections/>
      </metanorma>
    OUTPUT

    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(processor
      .input_to_isodoc(input, nil)).to_xml)))
      .to be_equivalent_to output
  end

  it "generates HTML from IsoDoc XML" do
    input = <<~INPUT
      <metanorma xmlns="http://riboseinc.com/isoxml">
        <sections>
          <terms id="H" obligation="normative" displayorder="1">
            <fmt-title>1<tab/>Terms, Definitions, Symbols and Abbreviated Terms</fmt-title>
            <term id="J">
            <fmt-name>1.1</fmt-name>
              <fmt-preferred><p>Term2</p></mt-preferred>
            </term>
          </terms>
        </sections>
      </metanorma>
    INPUT

    output = Xml::C14n.format(strip_guid(<<~OUTPUT))
       <main class="main-section">
         <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
         <div id="H">
           <h1 id="_">
             <a class="anchor" href="#H"/>
             <a class="header" href="#H">1  Terms, Definitions, Symbols and Abbreviated Terms</a>
           </h1>
           <p class="Terms" style="text-align:left;" id="J"><strong>1.1</strong> Term2</p>
         </div>
       </main>
    OUTPUT

    processor.output(input, "test.xml", "test.html", :html)

    expect(
      Xml::C14n.format(strip_guid(File.read("test.html", encoding: "utf-8")
        .gsub(%r{^.*<main}m, "<main")
        .gsub(%r{</main>.*}m, "</main>"))),
    ).to be_equivalent_to output
  end
end
