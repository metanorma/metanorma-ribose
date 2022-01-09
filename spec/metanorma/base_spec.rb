require "spec_helper"
require "fileutils"

OPTIONS = [backend: :ribose, header_footer: true].freeze

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

    output = xmlpp(<<~"OUTPUT")
      #{@blank_hdr}
      <sections/>
      </rsd-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to output
  end

  it "converts a blank document" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT

    output = xmlpp(<<~"OUTPUT")
      #{@blank_hdr}
      <sections/>
      </rsd-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to output
    expect(File.exist?("test.html")).to be true
    expect(File.exist?("test.doc")).to be true
    expect(File.exist?("test.pdf")).to be true
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
      <rsd-standard xmlns="https://www.metanorma.org/ns/rsd" type="semantic" version="#{Metanorma::Ribose::VERSION}">
      <bibdata type="standard">
        <title language="en" format="text/plain">Main Title</title>
      <docidentifier type="Ribose">1000(wd)</docidentifier>
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
      <sections/>
      </rsd-standard>
    OUTPUT

    output = output
      .sub(%r{</bibdata>}, "</bibdata>\n#{boilerplate(Nokogiri::XML(output))}")

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes custom publisher" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: standard
      :publisher: Fred
      :pub-address: 10 Jack St + \\
      Antarctica
      :pub-email: me@me.com
      :pub-uri: me.example.com
    INPUT
    output = xmlpp(<<~"OUTPUT")
          <rsd-standard xmlns='https://www.metanorma.org/ns/rsd' type='semantic' version='#{Metanorma::Ribose::VERSION}'>
        <bibdata type='standard'>
          <title language='en' format='text/plain'>Document title</title>
          <docidentifier type='Ribose'>1000</docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type='author'/>
            <organization>
              <name>Fred</name>
            </organization>
          </contributor>
          <contributor>
            <role type='publisher'/>
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
            <from>2021</from>
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
            <doctype>standard</doctype>
          </ext>
        </bibdata>
        <boilerplate>
          <copyright-statement>
            <clause>
              <p id='_'> &#169; Fred 2021</p>
            </clause>
          </copyright-statement>
          <legal-statement>
            <clause>
              <p id='_'>
                All rights reserved. Unless otherwise specified, no part of this
                publication may be reproduced or utilized otherwise in any form or by
                any means, electronic or mechanical, including photocopying, or
                posting on the internet or an intranet, without prior written
                permission. Permission can be requested from the address below.
              </p>
            </clause>
          </legal-statement>
          <feedback-statement>
            <clause>
              <p align='left' id='boilerplate-name'> Fred </p>
              <p align='left' id='boilerplate-address'>
              10 Jack St
                <br/>
                Antarctica
                <br/>
                <br/>
                <link target='mailto:me@me.com'>me@me.com</link>
                <br/>
                <link target='me.example.com'>me.example.com</link>
              </p>
            </clause>
          </feedback-statement>
        </boilerplate>
        <sections> </sections>
      </rsd-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to output
  end

  it "processes committee-draft" do
    out = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    expect(out).to include "<license-statement>"
    expect(xmlpp(strip_guid(Nokogiri::XML(out).at("//xmlns:bibdata").to_xml)))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <bibdata type="standard">
          <title language="en" format="text/plain">Main Title</title>
          <docidentifier type="Ribose">1000(cd)</docidentifier>
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
      OUTPUT
  end

  it "processes draft-standard" do
    out = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    expect(out).to include "<license-statement>"
    expect(xmlpp(strip_guid(Nokogiri::XML(out).at("//xmlns:bibdata").to_xml)))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <bibdata type="standard">
          <title language="en" format="text/plain">Main Title</title>
          <docidentifier type="Ribose">1000(d)</docidentifier>
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
      <bibdata type='standard'>
        <title language='en' format='text/plain'>Main Title</title>
        <docidentifier type="Ribose">1000</docidentifier>
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
    OUTPUT

    out = Asciidoctor.convert(input, *OPTIONS)
    expect(xmlpp(strip_guid(Nokogiri::XML(out).at("//xmlns:bibdata").to_xml)))
      .to be_equivalent_to xmlpp(output)
  end

  it "strips inline header" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
    INPUT

    output = xmlpp(<<~"OUTPUT")
        #{@blank_hdr}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">This is a preamble</p>
          </foreword>
        </preface>
        <sections>
          <clause id="_" obligation="normative">
            <title>Section 1</title>
          </clause>
        </sections>
      </rsd-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to output
  end

  it "uses default fonts" do
    input = <<~"INPUT"
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
    input = <<~"INPUT"
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
    input = <<~"INPUT"
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
        #{@blank_hdr}
        <sections>
          <p id="_">
            <em>emphasis</em>
            <strong>strong</strong>
            <tt>monospace</tt>“double quote”
               ‘single quote’
               super
            <sup>script</sup>
            sub
            <sub>script</sub>
            <stem type="MathML">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <msub>
                  <mrow>
                    <mi>a</mi></mrow>
                  <mrow>
                    <mn>90</mn>
                  </mrow>
                </msub>
              </math>
            </stem>
            <stem type="MathML">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <msub>
                  <mrow>
                    <mrow>
                      <mi mathvariant="bold-italic">F</mi>
                    </mrow>
                  </mrow>
                  <mrow>
                    <mrow>
                      <mi mathvariant="bold-italic">Α</mi>
                    </mrow>
                  </mrow>
                </msub>
              </math>
            </stem>
            <keyword>keyword</keyword>
            <strike>strike</strike>
            <smallcap>smallcap</smallcap>
          </p>
        </sections>
      </rsd-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to output
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

    output = xmlpp(<<~"OUTPUT")
        #{@blank_hdr.sub(/<status>/, '<abstract> <p>Abstract</p> </abstract> <status>')}
        <preface>
          <abstract id='_'>
          <title>Abstract</title>
            <p id='_'>Abstract</p>
          </abstract>
          <foreword id='_' obligation='informative'>
            <title>Foreword</title>
            <p id='_'>Foreword</p>
          </foreword>
          <executivesummary id='_'>
            <title>Executive Summary</title>
            <p id='_'>Executive Summary</p>
          </executivesummary>
          <introduction id='_' obligation='informative'>
            <title>Introduction</title>
            <p id='_'>Introduction</p>
          </introduction>
          <clause id='_' obligation='informative'>
            <title>Prefatory</title>
            <p id='_'>Prefatory</p>
          </clause>
        </preface>
        <sections> </sections>
      </rsd-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to output
  end
end
