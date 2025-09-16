require "spec_helper"

logoloc = File.join(
  File.expand_path(File.join(File.dirname(__FILE__), "..", "..")),
  "lib", "isodoc", "ribose", "html"
)

RSpec.describe IsoDoc::Ribose do
  it "processes default metadata" do
    csdc = IsoDoc::Ribose::HtmlConvert.new({})
    input = <<~INPUT
            <rsd-standard xmlns="https://open.ribose.com/standards/rsd">
            <bibdata type="standard">
              <title language="en" format="plain">Main Title</title>
              <docidentifier>1000(wd)</docidentifier>
              <docnumber>1000</docnumber>
              <edition>2</edition>
              <version>
              <revision-date>2000-01-01</revision-date>
              <draft>3.4</draft>
            </version>
              <contributor>
                <role type="author"/>
                <organization>
                  <name>Ribose</name>
                </organization>
              </contributor>
      <contributor>
         <role type="author">
            <description>committee</description>
         </role>
         <organization>
            <name>Ribose Asia Limited</name>
            <subdivision type="Committee" subtype="A">
               <name>TC</name>
               <identifier>A 1</identifier>
               <identifier type="full">A 1</identifier>
            </subdivision>
         </organization>
      </contributor>
      <contributor>
         <role type="author">
            <description>committee</description>
         </role>
         <organization>
            <name>Ribose Asia Limited</name>
            <subdivision type="Committee" subtype="A1">
               <name>TC1</name>
               <identifier>A1 11</identifier>
               <identifier type="full">A1 11</identifier>
            </subdivision>
         </organization>
      </contributor>
              <contributor>
                <role type="publisher"/>
                <organization>
              <name>Fred</name>
              <abbreviation>Fr</abbreviation>
              <address>
        <formattedAddress>10 Jack St<br/>Antarctica</formattedAddress>
      </address>
      <email>me@me.com</email>
      <uri>me.example.com</uri>
            </organization>
              </contributor>
              <language>en</language>
              <script>Latn</script>
              <status><stage>working-draft</stage></status>
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
              </editorialgroup>
              <security>Client Confidential</security>
              <recipient>Fred</recipient>
              </ext>
            </bibdata>
            <semantic-metadata>
         <stage-published>false</stage-published>
      </semantic-metadata>
            <sections/>
            </rsd-standard>
    INPUT

    output =
      { accesseddate: "XXX",
        adapteddate: "XXX",
        agency: "Fr",
        announceddate: "XXX",
        circulateddate: "XXX",
        confirmeddate: "XXX",
        copieddate: "XXX",
        correcteddate: "XXX",
        createddate: "XXX",
        docnumber: "1000(wd)",
        docnumeric: "1000",
        doctitle: "Main Title",
        doctype: "Standard",
        doctype_display: "Standard",
        docyear: "2001",
        draft: "3.4",
        draftinfo: " (draft 3.4, 2000-01-01)",
        edition: "2",
        implementeddate: "XXX",
        issueddate: "XXX",
        lang: "en",
        logo: "#{File.join(logoloc, 'logo.png')}",
        metadata_extensions: { "doctype" => "standard",
                               "editorialgroup" => { "committee_type" => "A", "committee" => "TC" }, "security" => "Client Confidential", "recipient" => "Fred" },
        obsoleteddate: "XXX",
        pub_address: "10 Jack St<br/>Antarctica",
        pub_email: "me@me.com",
        pub_uri: "me.example.com",
        publisheddate: "XXX",
        publisher: "Fred",
        receiveddate: "XXX",
        revdate: "2000-01-01",
        revdate_MMMddyyyy: "January 01, 2000",
        revdate_monthyear: "January 2000",
        script: "Latn",
        stable_untildate: "XXX",
        stage: "Working Draft",
        stage_display: "Working Draft",
        stageabbr: "wd",
        tc: "TC",
        transmitteddate: "XXX",
        unchangeddate: "XXX",
        unpublished: true,
        updateddate: "XXX",
        vote_endeddate: "XXX",
        vote_starteddate: "XXX" }

    docxml, = csdc.convert_init(input, "test", true)
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s)
      .gsub(/, :/, ",\n:")).to be_equivalent_to output
  end

  it "processes section names" do
    input = <<~INPUT
      <rsd-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <executivesummary id="A1" obligation="informative">
            <title>Executive Summary</title>
          </executivesummary>
          <introduction id="B" obligation="informative">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title>Introduction Subsection</title>
            </clause>
          </introduction>
        </preface>
        <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative">
            <title>Terms, definitions, symbols and abbreviated terms</title>
            <terms id="I" obligation="normative">
              <title>Normal Terms</title>
              <term id="J">
                <preferred><expression><name>Term2</name></expression></preferred>
              </term>
            </terms>
            <definitions id="K">
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </clause>
          <definitions id="L">
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative">
            <title>Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title>Introduction</title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title>Clause 4.2</title>
            </clause>
          </clause>
        </sections>
        <annex id="P" inline-header="false" obligation="normative">
          <title>Annex</title>
          <clause id="Q" inline-header="false" obligation="normative">
            <title>Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
              <title>Annex A.1a</title>
            </clause>
          </clause>
        </annex>
        <bibliography>
          <references id="R" normative="true" obligation="informative">
            <title>Normative References</title>
          </references>
          <clause id="S" obligation="informative">
            <title>Bibliography</title>
            <references id="T" normative="false" obligation="informative">
              <title>Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </rsd-standard>
    INPUT

    presxml = <<~OUTPUT
      <rsd-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
             <foreword obligation="informative" displayorder="2" id="_">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="A">This is a preamble</p>
             </foreword>
             <executivesummary id="A1" obligation="informative" displayorder="3">
                <title id="_">Executive Summary</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Executive Summary</semx>
                </fmt-title>
             </executivesummary>
             <introduction id="B" obligation="informative" displayorder="4">
                <title id="_">Introduction</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="B">0</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="C">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Introduction Subsection</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="B">0</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="C">1</semx>
                   </fmt-xref-label>
                </clause>
             </introduction>
          </preface>
          <sections>
             <clause id="D" obligation="normative" type="scope" displayorder="5">
                <title id="_">Scope</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="D">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Scope</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="D">1</semx>
                </fmt-xref-label>
                <p id="E">Text</p>
             </clause>
             <clause id="H" obligation="normative" displayorder="7">
                <title id="_">Terms, definitions, symbols and abbreviated terms</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Terms, definitions, symbols and abbreviated terms</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="H">3</semx>
                </fmt-xref-label>
                <terms id="I" obligation="normative">
                   <title id="_">Normal Terms</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Normal Terms</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="I">1</semx>
                   </fmt-xref-label>
                   <term id="J">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="H">3</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="I">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="J">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <semx element="autonum" source="H">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="J">1</semx>
                      </fmt-xref-label>
                                     <preferred id="_">
                  <expression>
                     <name>Term2</name>
                  </expression>
               </preferred>
               <fmt-preferred>
                  <p>
                     <semx element="preferred" source="_">Term2</semx>
                  </p>
               </fmt-preferred>
                   </term>
                </terms>
                <definitions id="K">
                   <title id="_">Symbols</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="K">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Symbols</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="K">2</semx>
                   </fmt-xref-label>
                   <dl>
                      <dt>Symbol</dt>
                      <dd>Definition</dd>
                   </dl>
                </definitions>
             </clause>
             <definitions id="L" displayorder="8">
                <title id="_">Symbols</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="L">4</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Symbols</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="L">4</semx>
                </fmt-xref-label>
                <dl>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="9">
                <title id="_">Clause 4</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 4</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="M">5</semx>
                </fmt-xref-label>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">5</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="N">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Introduction</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="N">1</semx>
                   </fmt-xref-label>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">5</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="O">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Clause 4.2</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="O">2</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
             <references id="R" normative="true" obligation="informative" displayorder="6">
                <title id="_">Normative References</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="R">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="R">2</semx>
                </fmt-xref-label>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="10">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="P">A</semx>
                   </span>
                </strong>
                <br/>
                <span class="fmt-obligation">(normative)</span>
                <span class="fmt-caption-delim">
                   <br/>
                   <br/>
                </span>
                <semx element="title" source="_">
                   <strong>Annex</strong>
                </semx>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="P">A</semx>
             </fmt-xref-label>
             <clause id="Q" inline-header="false" obligation="normative" autonum="A.1">
                <title id="_">Annex A.1</title>
                <fmt-title id="_" depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Annex A.1</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="P">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Q">1</semx>
                </fmt-xref-label>
                <clause id="Q1" inline-header="false" obligation="normative" autonum="A.1.1">
                   <title id="_">Annex A.1a</title>
                   <fmt-title id="_" depth="3">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="P">A</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q1">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Annex A.1a</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q1">1</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
          </annex>
          <bibliography>
             <clause id="S" obligation="informative" displayorder="11">
                <title id="_">Bibliography</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <references id="T" normative="false" obligation="informative">
                   <title id="_">Bibliography Subsection</title>
                   <fmt-title id="_" depth="2">
                      <semx element="title" source="_">Bibliography Subsection</semx>
                   </fmt-title>
                </references>
             </clause>
          </bibliography>
       </rsd-standard>
    OUTPUT

    output = Canon.format_xml(<<~"OUTPUT")
       #{HTML_HDR}
          <br/>
          <div id="_" class="TOC">
            <h1 class="IntroTitle">Contents</h1>
          </div>
          <br/>
          <div id="_">
            <h1 class="ForewordTitle">Foreword</h1>
            <p id="A">This is a preamble</p>
          </div>
          <br/>
          <div class="Section3" id="A1">
            <h1 class="IntroTitle">Executive Summary</h1>
          </div>
          <br/>
          <div class="Section3" id="B">
            <h1 class="IntroTitle">Introduction</h1>
            <div id="C">
              <h2>0.1.  Introduction Subsection</h2>
            </div>
          </div>
          <div id="D">
            <h1>1.  Scope</h1>
            <p id="E">Text</p>
          </div>
          <div>
            <h1>2.  Normative References</h1>
          </div>
          <div id="H">
            <h1>3.  Terms, definitions, symbols and abbreviated terms</h1>
            <div id="I">
              <h2>3.1.  Normal Terms</h2>
              <p class="TermNum" id="J">3.1.1.</p>
              <p class="Terms" style="text-align:left;">Term2</p>
            </div>
            <div id="K">
            <h2>3.2.  Symbols</h2>
              <div class="figdl">
              <dl>
                <dt>
                  <p>Symbol</p>
                </dt>
                <dd>Definition</dd>
              </dl>
              </div>
            </div>
          </div>
          <div id="L" class="Symbols">
          <h1>4.  Symbols</h1>
            <div class="figdl">
            <dl>
              <dt>
                <p>Symbol</p>
              </dt>
              <dd>Definition</dd>
            </dl>
            </div>
          </div>
          <div id="M">
            <h1>5.  Clause 4</h1>
            <div id="N">
              <h2>5.1.  Introduction</h2>
            </div>
            <div id="O">
              <h2>5.2.  Clause 4.2</h2>
            </div>
          </div>
          <br/>
          <div id="P" class="Section3">
            <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
            <div id="Q">
              <h2>A.1.  Annex A.1</h2>
              <div id="Q1">
                <h3>A.1.1.  Annex A.1a</h3>
              </div>
            </div>
          </div>
          <br/>
          <div>
            <h1 class="Section3">Bibliography</h1>
            <div>
              <h2 class="Section3">Bibliography Subsection</h2>
            </div>
          </div>
        </div>
      </body>
    OUTPUT

    pres_output = IsoDoc::Ribose::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Ribose::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))).to be_equivalent_to output
  end

  it "processes introduction with no subsections" do
    input = <<~INPUT
      <rsd-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword obligation="informative" id="A">
            <title>Foreword</title>
            <p>This is a preamble before <xref target="B"/></p>
          </foreword>
          <introduction id="B" obligation="informative">
            <title>Introduction</title>
          </introduction>
        </preface>
      </rsd-standard>
    INPUT
    presxml = <<~OUTPUT
      <rsd-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Contents</fmt-title>
            </clause>
            <foreword obligation="informative" id="A" displayorder="2">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <p>
                  This is a preamble before
                             <xref target="B" id="_"/>
          <semx element="xref" source="_">
             <fmt-xref target="B">
                <semx element="introduction" source="B">Introduction</semx>
             </fmt-xref>
          </semx>
               </p>
            </foreword>
            <introduction id="B" obligation="informative" displayorder="3">
               <title id="_">Introduction</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Introduction</semx>
               </fmt-title>
            </introduction>
         </preface>
      </rsd-standard>
    OUTPUT
    output = <<~OUTPUT
        #{HTML_HDR}
            <br/>
          <div id="_" class="TOC">
            <h1 class="IntroTitle">Contents</h1>
          </div>
              <br/>
          <div id="A">
            <h1 class='ForewordTitle'>Foreword</h1>
            <p>
               This is a preamble before
              <a href='#B'>Introduction</a>
            </p>
          </div>
          <br/>
          <div class='Section3' id='B'>
            <h1 class='IntroTitle'>Introduction</h1>
          </div>
        </div>
      </body>
    OUTPUT
    pres_output = IsoDoc::Ribose::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Ribose::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))).to be_equivalent_to output
  end

  it "injects JS into blank html" do
    system "rm -f test.html"
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
    INPUT

    output = Canon.format_xml(<<~"OUTPUT")
        #{blank_hdr_gen}
        <sections/>
      </rsd-standard>
    OUTPUT

    expect(Canon.format_xml(strip_guid(Asciidoctor
      .convert(input, backend: :ribose, header_footer: true))))
      .to be_equivalent_to output
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r{jquery\.min\.js})
    expect(html).to match(%r{Source Sans Pro})
  end

  it "cross-references sections" do
    input = <<~INPUT
      <rsd-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble
              <xref target="C"/>
              <xref target="C1"/>
              <xref target="D"/>
              <xref target="H"/>
              <xref target="I"/>
              <xref target="J"/>
              <xref target="K"/>
              <xref target="L"/>
              <xref target="M"/>
              <xref target="N"/>
              <xref target="O"/>
              <xref target="P"/>
              <xref target="Q"/>
              <xref target="Q1"/>
              <xref target="Q2"/>
              <xref target="R"/>
            </p>
          </foreword>
          <introduction id="B" obligation="informative">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title>Introduction Subsection</title>
            </clause>
            <clause id="C1" inline-header="false" obligation="informative">Text</clause>
          </introduction>
        </preface>
        <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>

          <terms id="H" obligation="normative">
            <title>Terms, definitions, symbols and abbreviated terms</title>
            <terms id="I" obligation="normative">
              <title>Normal Terms</title>
              <term id="J">
                <preferred>Term2</preferred>
              </term>
            </terms>
            <definitions id="K">
              <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
              </dl>
            </definitions>
          </terms>
          <definitions id="L">
            <dl>
            <dt>Symbol</dt>
            <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative">
            <title>Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title>Introduction</title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title>Clause 4.2</title>
            </clause>
          </clause>
        </sections>
        <annex id="P" inline-header="false" obligation="normative">
          <title>Annex</title>
          <clause id="Q" inline-header="false" obligation="normative">
            <title>Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
              <title>Annex A.1a</title>
            </clause>
          </clause>
          <appendix id="Q2" inline-header="false" obligation="normative">
            <title>An Appendix</title>
          </appendix>
        </annex>
        <bibliography>
          <references id="R" obligation="informative" normative="true">
            <title>Normative References</title>
          </references>
          <clause id="S" obligation="informative">
            <title>Bibliography</title>
            <references id="T" obligation="informative" normative="false">
              <title>Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </rsd-standard>
    INPUT
    output = <<~OUTPUT
      <foreword obligation="informative" id="_" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p id="A">
            This is a preamble
            <xref target="C" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C">
                  <semx element="autonum" source="B">0</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="C">1</semx>
               </fmt-xref>
            </semx>
            <xref target="C1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C1">
                  <semx element="autonum" source="B">0</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="C1">2</semx>
               </fmt-xref>
            </semx>
            <xref target="D" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="D">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="D">1</semx>
               </fmt-xref>
            </semx>
            <xref target="H" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="H">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="H">3</semx>
               </fmt-xref>
            </semx>
            <xref target="I" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="I">
                  <semx element="autonum" source="H">3</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="I">1</semx>
               </fmt-xref>
            </semx>
            <xref target="J" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="J">
                  <semx element="autonum" source="H">3</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="I">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="J">1</semx>
               </fmt-xref>
            </semx>
            <xref target="K" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="K">
                  <semx element="autonum" source="H">3</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="K">2</semx>
               </fmt-xref>
            </semx>
            <xref target="L" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="L">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="L">4</semx>
               </fmt-xref>
            </semx>
            <xref target="M" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="M">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="M">5</semx>
               </fmt-xref>
            </semx>
            <xref target="N" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N">
                  <semx element="autonum" source="M">5</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="N">1</semx>
               </fmt-xref>
            </semx>
            <xref target="O" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="O">
                  <semx element="autonum" source="M">5</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="O">2</semx>
               </fmt-xref>
            </semx>
            <xref target="P" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="P">
                  <span class="fmt-element-name">Annex</span>
                  <semx element="autonum" source="P">A</semx>
               </fmt-xref>
            </semx>
            <xref target="Q" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Q">
                  <span class="fmt-element-name">Annex</span>
                  <semx element="autonum" source="P">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Q1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Q1">
                  <span class="fmt-element-name">Annex</span>
                  <semx element="autonum" source="P">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Q2" id="_"/>
            <semx element="xref" source="_">
                     <fmt-xref target="Q2">
            <span class="fmt-xref-container">
               <span class="fmt-element-name">Annex</span>
               <semx element="autonum" source="P">A</semx>
            </span>
            <span class="fmt-comma">,</span>
            <span class="fmt-element-name">Appendix</span>
            <semx element="autonum" source="Q2">1</semx>
         </fmt-xref>
            </semx>
            <xref target="R" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="R">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="R">2</semx>
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(IsoDoc::Ribose::PresentationXMLConvert.new(presxml_options)
    .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes simple terms & definitions" do
    input = <<~INPUT
      <ogc-standard xmlns="https://standards.opengeospatial.org/document">
        <sections>
        <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
          <term id="J">
          <preferred><expression><name>Term2</name></expression></preferred>
          <admitted><expression><name>Term2A</name></expression></admitted>
          <admitted><expression><name>Term2B</name></expression></admitted>
          <deprecates><expression><name>Term2C</name></expression></deprecates>
          <deprecates><expression><name>Term2D</name></expression></deprecates>
          <source status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
          <modification>
          <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
        </modification>
      </source>
        </term>
         </terms>
         </sections>
         </ogc-standard>
    INPUT

    presxml = <<~INPUT
     <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <terms id="H" obligation="normative" displayorder="2">
                <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="H">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Terms, Definitions, Symbols and Abbreviated Terms</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="H">1</semx>
                </fmt-xref-label>
                <term id="J">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="J">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <semx element="autonum" source="H">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="J">1</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>Term2</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">Term2</semx>
                      </p>
                   </fmt-preferred>
                   <admitted id="_">
                      <expression>
                         <name>Term2A</name>
                      </expression>
                   </admitted>
                   <admitted id="_">
                      <expression>
                         <name>Term2B</name>
                      </expression>
                   </admitted>
                   <fmt-admitted>
                      <p>
                         <semx element="admitted" source="_">Term2A</semx>
                      </p>
                      <p>
                         <semx element="admitted" source="_">Term2B</semx>
                      </p>
                   </fmt-admitted>
                   <deprecates id="_">
                      <expression>
                         <name>Term2C</name>
                      </expression>
                   </deprecates>
                   <deprecates id="_">
                      <expression>
                         <name>Term2D</name>
                      </expression>
                   </deprecates>
                   <fmt-deprecates>
                      <p>
                         DEPRECATED:
                         <semx element="deprecates" source="_">Term2C</semx>
                      </p>
                      <p>
                         DEPRECATED:
                         <semx element="deprecates" source="_">Term2D</semx>
                      </p>
                   </fmt-deprecates>
                   <source status="modified" id="_">
                      <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </origin>
                      <modification id="_">
                         <p id="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                      </modification>
                   </source>
                   <fmt-termsource status="modified">
                      <strong>SOURCE</strong>
                      :
                      <semx element="source" source="_">
                         <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011" id="_">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                               <locality type="clause">
                                  <referenceFrom>3.1</referenceFrom>
                               </locality>
                               ISO 7301:2011, Clause 3.1
                            </fmt-origin>
                         </semx>
                         , modified —
                         <semx element="modification" source="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</semx>
                      </semx>
                   </fmt-termsource>
                </term>
             </terms>
          </sections>
       </ogc-standard>
    INPUT

    output = Canon.format_xml(strip_guid(<<~OUTPUT))
      <div id='H'>
        <h1 id='_'><a class="anchor" href="#H"/><a class="header" href="#H">1.&#xA0; Terms, Definitions, Symbols and Abbreviated Terms</a></h1>
        <p class='Terms' style='text-align:left;' id='J'><strong>1.1.</strong>&#xa0;Term2</p>
        <p class='AltTerms' style='text-align:left;'>Term2A</p>
        <p class='AltTerms' style='text-align:left;'>Term2B</p>
        <p class='DeprecatedTerms' style='text-align:left;'>DEPRECATED: Term2C</p>
        <p class='DeprecatedTerms' style='text-align:left;'>DEPRECATED: Term2D</p>
         <p><b>SOURCE</b>:
        ISO&#xa0;7301:2011, Clause 3.1, modified &#x2014; The term "cargo rice" is shown as deprecated, and Note 1
        to entry is not included here
       </p>
      </div>
    OUTPUT

    pres_output = IsoDoc::Ribose::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output
     .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(presxml)
    IsoDoc::Ribose::HtmlConvert.new({ filename: "test" })
      .convert("test", pres_output, false)
    expect(Canon.format_xml(strip_guid(
                              File.read("test.html")
                           .gsub(%r{^.*<div id="H">}m, '<div id="H">')
                           .gsub(%r{</div>.*}m, "</div>"),
                            ))).to be_equivalent_to output
  end

  it "processes unordered lists" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <clause type="toc" id="_" displayorder="1"> <fmt-title id="_" depth="1">Table of contents</fmt-title> </clause>
          <foreword displayorder="2" id="fwd"><fmt-title id="_">Foreword</fmt-title>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddb"  keep-with-next="true" keep-lines-together="true">
          <name>Caption</name>
        <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a2">Level 1</p>
        </li>
        <li>
          <p id="_60eb765c-1f6c-418a-8016-29efa06bf4f9">deletion of 4.3.</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 2</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 3</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 4</p>
        </li>
        </ul>
        </li>
        </ul>
        </li>
          </ul>
        </li>
      </ul>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <foreword displayorder="1" id="fwd">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">Foreword</fmt-title>
                <ul id="_" keep-with-next="true" keep-lines-together="true">
                   <name id="_">Caption</name>
                   <fmt-name id="_">
                      <semx element="name" source="_">Caption</semx>
                   </fmt-name>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">o</semx>
                      </fmt-name>
                      <p id="_">Level 1</p>
                   </li>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">o</semx>
                      </fmt-name>
                      <p id="_">deletion of 4.3.</p>
                      <ul id="_" keep-with-next="true" keep-lines-together="true">
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">—</semx>
                            </fmt-name>
                            <p id="_">Level 2</p>
                            <ul id="_" keep-with-next="true" keep-lines-together="true">
                               <li id="_">
                                  <fmt-name id="_">
                                     <semx element="autonum" source="_">•</semx>
                                  </fmt-name>
                                  <p id="_">Level 3</p>
                                  <ul id="_" keep-with-next="true" keep-lines-together="true">
                                     <li id="_">
                                        <fmt-name id="_">
                                           <semx element="autonum" source="_">o</semx>
                                        </fmt-name>
                                        <p id="_">Level 4</p>
                                     </li>
                                  </ul>
                               </li>
                            </ul>
                         </li>
                      </ul>
                   </li>
                </ul>
             </foreword>
             <clause type="toc" id="_" displayorder="2">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
       </iso-standard>
    INPUT
    pres_output = IsoDoc::Ribose::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output
     .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "processes ordered lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword id="_" displayorder="2">
          <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" type="alphabet"  keep-with-next="true" keep-lines-together="true">
          <name>Caption</name>
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">Level 1</p>
          </li>
          </ol>
        <ol id="A">
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">Level 1</p>
          </li>
        <li>
          <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">Level 1</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 2</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 3</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 4</p>
        </li>
        </ol>
        </li>
        </ol>
        </li>
        </ol>
        </li>
        </ol>
        </li>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Contents</fmt-title>
            </clause>
            <foreword id="_" displayorder="2">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <ol id="_" type="alphabet" keep-with-next="true" keep-lines-together="true" autonum="1">
                  <name id="_">Caption</name>
                  <fmt-name id="_">
                     <semx element="name" source="_">Caption</semx>
                  </fmt-name>
                  <li id="_">
                     <fmt-name id="_">
                        <semx element="autonum" source="_">a</semx>
                        <span class="fmt-label-delim">.</span>
                     </fmt-name>
                     <p id="_">Level 1</p>
                  </li>
               </ol>
               <ol id="A" type="alphabet">
                  <li id="_">
                     <fmt-name id="_">
                        <semx element="autonum" source="_">a</semx>
                        <span class="fmt-label-delim">.</span>
                     </fmt-name>
                     <p id="_">Level 1</p>
                  </li>
                  <li id="_">
                     <fmt-name id="_">
                        <semx element="autonum" source="_">b</semx>
                        <span class="fmt-label-delim">.</span>
                     </fmt-name>
                     <p id="_">Level 1</p>
                     <ol type="arabic">
                        <li id="_">
                           <fmt-name id="_">
                              <semx element="autonum" source="_">1</semx>
                              <span class="fmt-label-delim">.</span>
                           </fmt-name>
                           <p id="_">Level 2</p>
                           <ol type="roman">
                              <li id="_">
                                 <fmt-name id="_">
                                    <semx element="autonum" source="_">i</semx>
                                    <span class="fmt-label-delim">.</span>
                                 </fmt-name>
                                 <p id="_">Level 3</p>
                                 <ol type="alphabet_upper">
                                    <li id="_">
                                       <fmt-name id="_">
                                          <semx element="autonum" source="_">A</semx>
                                          <span class="fmt-label-delim">.</span>
                                       </fmt-name>
                                       <p id="_">Level 4</p>
                                    </li>
                                 </ol>
                              </li>
                           </ol>
                        </li>
                     </ol>
                  </li>
               </ol>
            </foreword>
         </preface>
      </iso-standard>
    INPUT
    pres_output = IsoDoc::Ribose::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output
     .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(presxml)
  end
end
