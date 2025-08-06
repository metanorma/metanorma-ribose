require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Ribose do
  before(:all) do
    @blank_hdr = blank_hdr_gen
  end

  it "has a version number" do
    expect(Metanorma::Ribose::VERSION).not_to be nil
  end

  it "processes a blank document" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
    INPUT

    output = Canon.format_xml(<<~"OUTPUT")
      #{@blank_hdr}
      <sections/>
      </metanorma>
    OUTPUT

    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to output
  end

  it "converts a blank document" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT

    output = Canon.format_xml(<<~"OUTPUT")
      #{@blank_hdr}
      <sections/>
      </metanorma>
    OUTPUT

    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to output
    expect(File.exist?("test.html")).to be true
    expect(File.exist?("test.doc")).to be true
    expect(File.exist?("test.pdf")).to be true
  end

  it "processes default metadata" do
    input = <<~INPUT
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

    output = Canon.format_xml(<<~"OUTPUT")
      <?xml version="1.0" encoding="UTF-8"?>
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Ribose::VERSION}" flavor="ribose">
              <bibdata type="standard">
           <title language="en" format="text/plain">Main Title</title>
           <docidentifier primary="true" type="Ribose">1000(wd)</docidentifier>
           <docnumber>1000</docnumber>
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
                 <name>Ribose Asia Limited</name>
                 <abbreviation>Ribose</abbreviation>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype>standard</doctype>
      <flavor>ribose</flavor>
             <editorialgroup>
               <committee type="A">TC</committee>
               <committee type="A1">TC1</committee>
             </editorialgroup>
             <security>Client Confidential</security>
             <recipient>tbd@example.com</recipient>
           </ext>
         </bibdata>
         <metanorma-extension>
      <semantic-metadata>
         <stage-published>false</stage-published>
      </semantic-metadata>
           <presentation-metadata>
             <name>TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>HTML TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>DOC TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>PDF TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
         </metanorma-extension>
         <sections/>
       </metanorma>
    OUTPUT

    output = output
      .sub(%r{</metanorma-extension>},
           "</metanorma-extension>\n#{boilerplate(Nokogiri::XML(output))}")

    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes custom publisher" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: code
      :publisher: Fred
      :pub-address: 10 Jack St + \\
      Antarctica
      :pub-email: me@me.com
      :pub-uri: me.example.com
    INPUT
    output = Canon.format_xml(<<~"OUTPUT")
          <metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' version='#{Metanorma::Ribose::VERSION}' flavor="ribose">
          <bibdata type="standard">
           <title language="en" format="text/plain">Document title</title>
           <docidentifier primary="true" type="Ribose">Code 1000</docidentifier>
           <docnumber>1000</docnumber>
           <contributor>
             <role type="author"/>
             <organization>
               <name>Fred</name>
               <address>
                 <formattedAddress>10 Jack St<br/>Antarctica</formattedAddress>
               </address>
               <email>me@me.com</email>
               <uri>me.example.com</uri>
             </organization>
           </contributor>
           <contributor>
             <role type="publisher"/>
             <organization>
               <name>Fred</name>
               <address>
                 <formattedAddress>10 Jack St<br/>Antarctica</formattedAddress>
               </address>
               <email>me@me.com</email>
               <uri>me.example.com</uri>
             </organization>
           </contributor>
           <language>en</language>
           <script>Latn</script>
           <status>
             <stage>published</stage>
           </status>
           <copyright>
             <from>#{Date.today.year}</from>
             <owner>
               <organization>
                 <name>Fred</name>
                 <address>
                   <formattedAddress>10 Jack St<br/>Antarctica</formattedAddress>
                 </address>
                 <email>me@me.com</email>
                 <uri>me.example.com</uri>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype abbreviation="Code">code</doctype>
      <flavor>ribose</flavor>
           </ext>
         </bibdata>
         <metanorma-extension>
      <semantic-metadata>
         <stage-published>true</stage-published>
      </semantic-metadata>
           <presentation-metadata>
             <name>TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>HTML TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>DOC TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>PDF TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
         </metanorma-extension>
         <boilerplate>
           <copyright-statement>
             <clause id="_" obligation="normative">
               <p id="_">© Fred #{Date.today.year}</p>
             </clause>
           </copyright-statement>
           <legal-statement>
             <clause id="_" obligation="normative">
               <p id="_">All rights reserved. Unless otherwise specified, no part of this
       publication may be reproduced or utilized otherwise in any form or by any
       means, electronic or mechanical, including photocopying, or posting on the
       internet or an intranet, without prior written permission. Permission can
       be requested from the address below.</p>
             </clause>
           </legal-statement>
           <feedback-statement>
             <clause id="_" obligation="normative">
               <p id="_" anchor="boilerplate-name" align="left">Fred</p>
               <p id="_" anchor="boilerplate-address" align="left">10 Jack St<br/>Antarctica<br/><br/>
       me@me.com<br/>
       me.example.com</p>
             </clause>
           </feedback-statement>
         </boilerplate>
         <sections/>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to output
  end

  it "processes committee-draft" do
    out = Asciidoctor.convert(<<~INPUT, *OPTIONS)
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
    expect(out).to include("<license-statement>")
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(out).at("//xmlns:bibdata").to_xml)))
      .to be_equivalent_to Canon.format_xml(<<~"OUTPUT")
        <bibdata type="standard">
          <title language="en" format="text/plain">Main Title</title>
          <docidentifier primary="true" type="Ribose">1000(cd)</docidentifier>
          <docnumber>1000</docnumber>
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
      OUTPUT
  end

  it "processes draft-standard" do
    out = Asciidoctor.convert(<<~INPUT, *OPTIONS)
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
    expect(out).to include("<license-statement>")
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(out).at("//xmlns:bibdata").to_xml)))
      .to be_equivalent_to Canon.format_xml(<<~"OUTPUT")
        <bibdata type="standard">
          <title language="en" format="text/plain">Main Title</title>
          <docidentifier primary="true" type="Ribose">1000(d)</docidentifier>
          <docnumber>1000</docnumber>
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
      OUTPUT
  end

  it "ignores unrecognised status" do
    input = <<~INPUT
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

    output = <<~OUTPUT
      <bibdata type='standard'>
        <title language='en' format='text/plain'>Main Title</title>
        <docidentifier primary="true" type="Ribose">1000</docidentifier>
        <docnumber>1000</docnumber>
        <contributor>
          <role type='author'/>
          <organization>
                    <name>Ribose Asia Limited</name>
          <abbreviation>Ribose</abbreviation>
          </organization>
        </contributor>
        <contributor>
          <role type='publisher'/>
          <organization>
                    <name>Ribose Asia Limited</name>
          <abbreviation>Ribose</abbreviation>
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
    OUTPUT

    out = Asciidoctor.convert(input, *OPTIONS)
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(out).at("//xmlns:bibdata").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "strips inline header" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
    INPUT

    output = Canon.format_xml(<<~"OUTPUT")
        #{@blank_hdr}
        <preface>
          <foreword id="_" obligation="informative">
            <title id="_">Foreword</title>
            <p id="_">This is a preamble</p>
          </foreword>
        </preface>
        <sections>
          <clause id="_" obligation="normative">
            <title id="_">Section 1</title>
          </clause>
        </sections>
      </metanorma>
    OUTPUT

    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to output
  end

  it "uses default fonts" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
    INPUT

    FileUtils.rm_f "test.html"
    Asciidoctor.convert(input, *OPTIONS)

    html = File.read("test.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^}]+font-family: "Source Code Pro", monospace;]m)
    expect(html)
      .to match(%r[ div[^{]+\{[^}]+font-family: "Source Sans Pro", sans-serif;]m)
    expect(html)
      .to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "Source Sans Pro", sans-serif;]m)
  end

  it "uses Chinese fonts" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :no-pdf:
    INPUT

    FileUtils.rm_f "test.html"
    Asciidoctor.convert(input, *OPTIONS)

    html = File.read("test.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^}]+font-family: "Source Code Pro", monospace;]m)
    expect(html)
      .to match(%r[ div[^{]+\{[^}]+font-family: "Source Han Sans", serif;]m)
    expect(html)
      .to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "Source Han Sans", sans-serif;]m)
  end

  it "uses specified fonts" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :body-font: Zapf Chancery
      :header-font: Comic Sans
      :monospace-font: Andale Mono
      :no-pdf:
    INPUT

    FileUtils.rm_f "test.html"
    Asciidoctor.convert(input, *OPTIONS)

    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: Zapf Chancery;]m)
    expect(html)
      .to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: Comic Sans;]m)
  end

  it "processes executive summaries" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}

      Foreword

      [abstract]
      == Abstract
      Abstract

      == Introduction
      Introduction

      == Executive Summary
      Executive Summary

      [.preface]
      == Prefatory
      Prefatory
    INPUT

    output = Canon.format_xml(<<~"OUTPUT")
        #{@blank_hdr.sub(/<status>/, '<abstract> <p>Abstract</p> </abstract> <status>')}
        <preface>
          <abstract id='_'>
          <title id="_">Abstract</title>
            <p id='_'>Abstract</p>
          </abstract>
          <foreword id='_' obligation='informative'>
            <title id="_">Foreword</title>
            <p id='_'>Foreword</p>
          </foreword>
          <executivesummary id='_' obligation="informative">
            <title id="_">Executive summary</title>
            <p id='_'>Executive Summary</p>
          </executivesummary>
          <introduction id='_' obligation='informative'>
            <title id="_">Introduction</title>
            <p id='_'>Introduction</p>
          </introduction>
          <clause id='_' obligation='informative'>
            <title id="_">Prefatory</title>
            <p id='_'>Prefatory</p>
          </clause>
        </preface>
        <sections> </sections>
      </metanorma>
    OUTPUT

    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to output
  end
end
