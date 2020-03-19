require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Rsd do
  it "has a version number" do
    expect(Metanorma::Rsd::VERSION).not_to be nil
  end

  it "processes a blank document" do
    input = <<~"INPUT"
    #{ASCIIDOC_BLANK_HDR}
    INPUT

    output = xmlpp(<<~"OUTPUT")
    #{BLANK_HDR}
<sections/>
</rsd-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :rsd, header_footer: true)))).to be_equivalent_to output
  end

  it "converts a blank document" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT

    output = xmlpp(<<~"OUTPUT")
    #{BLANK_HDR}
<sections/>
</rsd-standard>
    OUTPUT

    FileUtils.rm_f "test.html"
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :rsd, header_footer: true)))).to be_equivalent_to output
    expect(File.exist?("test.html")).to be true
  end

  it "processes default metadata" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: standard
      :edition: 2
      :revdate: 2000-01-01
      :draft: 3.4
      :committee: TC
      :committee-number: 1
      :committee-type: A
      :committee_2: TC1
      :committee-number_2: 11
      :committee-type_2: A1
      :subcommittee: SC
      :subcommittee-number: 2
      :subcommittee-type: B
      :workgroup: WG
      :workgroup-number: 3
      :workgroup-type: C
      :secretariat: SECRETARIAT
      :copyright-year: 2001
      :status: working-draft
      :iteration: 3
      :language: en
      :title: Main Title
      :security: Client Confidential
      :recipient: tbd@example.com
      
    INPUT

    output = xmlpp(<<~"OUTPUT")
    <?xml version="1.0" encoding="UTF-8"?>
<rsd-standard xmlns="https://www.metanorma.org/ns/rsd">
<bibdata type="standard">
  <title language="en" format="text/plain">Main Title</title>
<docidentifier>1000(wd)</docidentifier>
<docnumber>1000</docnumber>
  <contributor>
    <role type="author"/>
    <organization>
      <name>Ribose</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>Ribose</name>
    </organization>
  </contributor>
  <edition>2</edition>
<version>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>working-draft</stage>
    <iteration>3</iteration>
  </status>
  <copyright>
    <from>2001</from>
    <owner>
      <organization>
        <name>Ribose</name>
      </organization>
    </owner>
  </copyright>
  <ext>
  <doctype>standard</doctype>
  <editorialgroup>
    <committee type="A">TC</committee>
    <committee type="A1">TC1</committee>
  </editorialgroup>
  <security>Client Confidential</security>
  <recipient>tbd@example.com</recipient>
  </ext>
</bibdata>
        #{BOILERPLATE.sub(/<legal-statement/, "#{LICENSE_BOILERPLATE}\n<legal-statement").sub(/Ribose Group Inc\. #{Time.new.year}/, "Ribose Group Inc. 2001")}
<sections/>
</rsd-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :rsd, header_footer: true)))).to be_equivalent_to output
  end

    it "processes committee-draft" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :rsd, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: standard
      :edition: 2
      :revdate: 2000-01-01
      :draft: 3.4
      :status: committee-draft
      :iteration: 3
      :language: en
      :title: Main Title
    INPUT
        <rsd-standard xmlns="https://www.metanorma.org/ns/rsd">
<bibdata type="standard">
  <title language="en" format="text/plain">Main Title</title>
  <docidentifier>1000(cd)</docidentifier>
  <docnumber>1000</docnumber>
  <contributor>
    <role type="author"/>
    <organization>
      <name>Ribose</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>Ribose</name>
    </organization>
  </contributor>
  <edition>2</edition>
<version>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>committee-draft</stage>
    <iteration>3</iteration>
  </status>
  <copyright>
    <from>#{Date.today.year}</from>
    <owner>
      <organization>
        <name>Ribose</name>
      </organization>
    </owner>
  </copyright>
  <ext>
  <doctype>standard</doctype>
  </ext>
</bibdata>
        #{BOILERPLATE.sub(/<legal-statement/, "#{LICENSE_BOILERPLATE}\n<legal-statement")}
<sections/>
</rsd-standard>
        OUTPUT
    end

            it "processes draft-standard" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :rsd, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: standard
      :edition: 2
      :revdate: 2000-01-01
      :draft: 3.4
      :status: draft-standard
      :iteration: 3
      :language: en
      :title: Main Title
    INPUT
        <rsd-standard xmlns="https://www.metanorma.org/ns/rsd">
<bibdata type="standard">
  <title language="en" format="text/plain">Main Title</title>
  <docidentifier>1000(d)</docidentifier>
  <docnumber>1000</docnumber>
  <contributor>
    <role type="author"/>
    <organization>
      <name>Ribose</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>Ribose</name>
    </organization>
  </contributor>
  <edition>2</edition>
<version>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>draft-standard</stage>
    <iteration>3</iteration>
  </status>
  <copyright>
    <from>#{Date.today.year}</from>
    <owner>
      <organization>
        <name>Ribose</name>
      </organization>
    </owner>
  </copyright>
  <ext>
  <doctype>standard</doctype>
  </ext>
</bibdata>
        #{BOILERPLATE.sub(/<legal-statement/, "#{LICENSE_BOILERPLATE}\n<legal-statement")}
<sections/>
</rsd-standard>
OUTPUT
        end

    it "ignores unrecognised status" do
      input = <<~"INPUT"
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :novalid:
        :docnumber: 1000
        :doctype: standard
        :edition: 2
        :revdate: 2000-01-01
        :draft: 3.4
        :copyright-year: 2001
        :status: standard
        :iteration: 3
        :language: en
        :title: Main Title
      INPUT

      output = <<~"OUTPUT"
       <rsd-standard xmlns='https://www.metanorma.org/ns/rsd'>
         <bibdata type='standard'>
           <title language='en' format='text/plain'>Main Title</title>
           <docidentifier>1000</docidentifier>
           <docnumber>1000</docnumber>
           <contributor>
             <role type='author'/>
             <organization>
               <name>Ribose</name>
             </organization>
           </contributor>
           <contributor>
             <role type='publisher'/>
             <organization>
               <name>Ribose</name>
             </organization>
           </contributor>
           <edition>2</edition>
           <version>
             <revision-date>2000-01-01</revision-date>
             <draft>3.4</draft>
           </version>
           <language>en</language>
           <script>Latn</script>
           <status>
             <stage>standard</stage>
             <iteration>3</iteration>
           </status>
           <copyright>
             <from>2001</from>
             <owner>
               <organization>
                 <name>Ribose</name>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype>standard</doctype>
           </ext>
         </bibdata>


        #{BOILERPLATE.sub(/<legal-statement/, "#{LICENSE_BOILERPLATE}\n<legal-statement").sub(/Ribose Group Inc\. #{Time.new.year}/, "Ribose Group Inc. 2001")}
        <sections/>
        </rsd-standard>
      OUTPUT

      expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :rsd, header_footer: true)))).to(be_equivalent_to(output))
    end

  it "strips inline header" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
    INPUT

    output = xmlpp(<<~"OUTPUT")
    #{BLANK_HDR}
             <preface><foreword id="_" obligation="informative">
         <title>Foreword</title>
         <p id="_">This is a preamble</p>
       </foreword></preface><sections>
       <clause id="_" obligation="normative">
         <title>Section 1</title>
       </clause></sections>
       </rsd-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :rsd, header_footer: true)))).to be_equivalent_to output
  end

  it "uses default fonts" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT

    FileUtils.rm_f "test.html"
    Asciidoctor.convert(input, backend: :rsd, header_footer: true)

    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Space Mono", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "Overpass", sans-serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "Overpass", sans-serif;]m)
  end

  it "uses Chinese fonts" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
    INPUT

    FileUtils.rm_f "test.html"
    Asciidoctor.convert(input, backend: :rsd, header_footer: true)

    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Space Mono", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "SimSun", serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "SimHei", sans-serif;]m)
  end

  it "uses specified fonts" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :body-font: Zapf Chancery
      :header-font: Comic Sans
      :monospace-font: Andale Mono
    INPUT

    FileUtils.rm_f "test.html"
    Asciidoctor.convert(input, backend: :rsd, header_footer: true)

    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: Comic Sans;]m)
  end

  it "processes inline_quoted formatting" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      _emphasis_
      *strong*
      `monospace`
      "double quote"
      'single quote'
      super^script^
      sub~script~
      stem:[a_90]
      stem:[<mml:math><mml:msub xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">F</mml:mi> </mml:mrow> </mml:mrow> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">&#x391;</mml:mi> </mml:mrow> </mml:mrow> </mml:msub> </mml:math>]
      [keyword]#keyword#
      [strike]#strike#
      [smallcap]#smallcap#
    INPUT

    output = xmlpp(<<~"OUTPUT")
            #{BLANK_HDR}
       <sections>
        <p id="_"><em>emphasis</em>
       <strong>strong</strong>
       <tt>monospace</tt>
       “double quote”
       ‘single quote’
       super<sup>script</sup>
       sub<sub>script</sub>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mi>a</mi><mn>90</mn></msub></math></stem>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub> <mrow> <mrow> <mi mathvariant="bold-italic">F</mi> </mrow> </mrow> <mrow> <mrow> <mi mathvariant="bold-italic">Α</mi> </mrow> </mrow> </msub> </math></stem>
       <keyword>keyword</keyword>
       <strike>strike</strike>
       <smallcap>smallcap</smallcap></p>
       </sections>
       </rsd-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :rsd, header_footer: true)))).to be_equivalent_to output
  end


end
