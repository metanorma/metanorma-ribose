require "spec_helper"

logoloc = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "isodoc", "ribose", "html"))

RSpec.describe IsoDoc::Ribose do

  it "processes default metadata" do
    csdc = IsoDoc::Ribose::HtmlConvert.new({})
    input = <<~"INPUT"
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
    <role type="publisher"/>
    <organization>
      <name>Ribose</name>
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
<sections/>
</rsd-standard>
    INPUT

    output = <<~"OUTPUT"
{:accesseddate=>"XXX",
:agency=>"Ribose",
:authors=>[],
:authors_affiliations=>{},
:circulateddate=>"XXX",
:confirmeddate=>"XXX",
:copieddate=>"XXX",
:createddate=>"XXX",
:docnumber=>"1000(wd)",
:docnumeric=>"1000",
:doctitle=>"Main Title",
:doctype=>"Standard",
:docyear=>"2001",
:draft=>"3.4",
:draftinfo=>" (draft 3.4, 2000-01-01)",
:edition=>"2",
:implementeddate=>"XXX",
:issueddate=>"XXX",
:keywords=>[],
:logo=>"#{File.join(logoloc, "logo.png")}",
:metadata_extensions=>{"doctype"=>"standard", "editorialgroup"=>{"committee_type"=>"A", "committee"=>"TC"}, "security"=>"Client Confidential", "recipient"=>"Fred"},
:obsoleteddate=>"XXX",
:publisheddate=>"XXX",
:publisher=>"Ribose",
:receiveddate=>"XXX",
:revdate=>"2000-01-01",
:revdate_MMMddyyyy=>"January 01, 2000",
:revdate_monthyear=>"January 2000",
:stage=>"Working Draft",
:stageabbr=>"wd",
:tc=>"TC",
:transmitteddate=>"XXX",
:unchangeddate=>"XXX",
:unpublished=>true,
:updateddate=>"XXX",
:vote_endeddate=>"XXX",
:vote_starteddate=>"XXX"}
    OUTPUT

    docxml, filename, dir = csdc.convert_init(input, "test", true)
    expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s).gsub(/, :/, ",\n:")).to be_equivalent_to output
  end

  it "processes pre" do
    input = <<~"INPUT"
<rsd-standard xmlns="https://open.ribose.com/standards/rsd">
<preface><foreword>
<pre>ABC</pre>
</foreword></preface>
</rsd-standard>
    INPUT

    output = xmlpp(<<~"OUTPUT")
    #{HTML_HDR}
             <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <pre>ABC</pre>
             </div>
             <p class="zzSTDTitle1"/>
           </div>
         </body>
    OUTPUT

    expect(xmlpp(
      IsoDoc::Ribose::HtmlConvert.new({}).
      convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to output
  end

  it "processes keyword" do
    input = <<~"INPUT"
<rsd-standard xmlns="https://open.ribose.com/standards/rsd">
<preface><foreword>
<keyword>ABC</keyword>
</foreword></preface>
</rsd-standard>
    INPUT

    output = xmlpp(<<~"OUTPUT")
        #{HTML_HDR}
             <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <span class="keyword">ABC</span>
             </div>
             <p class="zzSTDTitle1"/>
           </div>
         </body>
    OUTPUT

    expect(xmlpp(
      IsoDoc::Ribose::HtmlConvert.new({}).
      convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to output
  end

  it "processes section names" do
    input = <<~"INPUT"
    <rsd-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <executivesummary id="A1" obligation="informative"><title>Executive Summary</title>
        </executivesummary>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <clause id="H" obligation="normative"><title>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
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
       </clause>
       <definitions id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
       </annex><bibliography><references id="R" obligation="informative" normative="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </rsd-standard>
    INPUT

    presxml = <<~OUTPUT
    <rsd-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
         <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
           <executivesummary id="A1" obligation="informative"><title>Executive Summary</title>
           </executivesummary>
           <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
            <title depth="2">Introduction Subsection</title>
          </clause>
          </introduction></preface><sections>
          <clause id="D" obligation="normative" type="scope">
            <title depth="1">1.<tab/>Scope</title>
            <p id="E">Text</p>
          </clause>

          <clause id="H" obligation="normative"><title depth="1">3.<tab/>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
            <title depth="2">3.1.<tab/>Normal Terms</title>
            <term id="J"><name>3.1.1.</name>
            <preferred>Term2</preferred>
          </term>
          </terms>
          <definitions id="K"><title>3.2.</title>
            <dl>
            <dt>Symbol</dt>
            <dd>Definition</dd>
            </dl>
          </definitions>
          </clause>
          <definitions id="L"><title>4.</title>
            <dl>
            <dt>Symbol</dt>
            <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative"><title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
            <title depth="2">5.1.<tab/>Introduction</title>
          </clause>
          <clause id="O" inline-header="false" obligation="normative">
            <title depth="2">5.2.<tab/>Clause 4.2</title>
          </clause></clause>

          </sections><annex id="P" inline-header="false" obligation="normative">
            <title>Annex A<br/>(normative)<br/><br/>Annex</title>
            <clause id="Q" inline-header="false" obligation="normative">
            <title depth="2">A.1.<tab/>Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
            <title depth="3">A.1.1.<tab/>Annex A.1a</title>
            </clause>
          </clause>
          </annex><bibliography><references id="R" obligation="informative" normative="true">
            <title depth="1">2.<tab/>Normative References</title>
          </references><clause id="S" obligation="informative">
            <title depth="1">Bibliography</title>
            <references id="T" obligation="informative" normative="false">
            <title depth="2">Bibliography Subsection</title>
          </references>
          </clause>
          </bibliography>
          </rsd-standard>
          OUTPUT

    output = xmlpp(<<~"OUTPUT")
        #{HTML_HDR}
        <br/>
           <div>
             <h1 class='ForewordTitle'>Foreword</h1>
             <p id='A'>This is a preamble</p>
           </div>
           <br/>
           <div class='Section3' id='A1'>
             <h1 class='IntroTitle'>Executive Summary</h1>
           </div>
           <br/>
           <div class='Section3' id='B'>
             <h1 class='IntroTitle'>Introduction</h1>
             <div id='C'>
               <h2>Introduction Subsection</h2>
             </div>
           </div>
           <p class='zzSTDTitle1'/>
           <div id='D'>
             <h1>1.&#160; Scope</h1>
             <p id='E'>Text</p>
           </div>
           <div>
             <h1>2.&#160; Normative References</h1>
           </div>
           <div id='H'>
             <h1>3.&#160; Terms, definitions, symbols and abbreviated terms</h1>
             <div id='I'>
               <h2>3.1.&#160; Normal Terms</h2>
               <p class='TermNum' id='J'>3.1.1.</p>
               <p class='Terms' style='text-align:left;'>Term2</p>
             </div>
             <div id='K'>
               <h2>3.2.</h2>
               <dl>
                 <dt>
                   <p>Symbol</p>
                 </dt>
                 <dd>Definition</dd>
               </dl>
             </div>
           </div>
           <div id='L' class='Symbols'>
             <h1>4.</h1>
             <dl>
               <dt>
                 <p>Symbol</p>
               </dt>
               <dd>Definition</dd>
             </dl>
           </div>
           <div id='M'>
             <h1>5.&#160; Clause 4</h1>
             <div id='N'>
               <h2>5.1.&#160; Introduction</h2>
             </div>
             <div id='O'>
               <h2>5.2.&#160; Clause 4.2</h2>
             </div>
           </div>
           <br/>
           <div id='P' class='Section3'>
             <h1 class='Annex'>
               Annex A
               <br/>
               (normative)
               <br/>
               <br/>
               Annex
             </h1>
             <div id='Q'>
               <h2>A.1.&#160; Annex A.1</h2>
               <div id='Q1'>
                 <h3>A.1.1.&#160; Annex A.1a</h3>
               </div>
             </div>
           </div>
           <br/>
           <div>
             <h1 class='Section3'>Bibliography</h1>
             <div>
               <h2 class='Section3'>Bibliography Subsection</h2>
             </div>
           </div>
         </div>
       </body>
    OUTPUT

      expect((IsoDoc::Ribose::PresentationXMLConvert.new({}).convert("test", input, true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(
      IsoDoc::Ribose::HtmlConvert.new({}).convert("test", presxml, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to output
  end

  it "injects JS into blank html" do
    system "rm -f test.html"
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
    INPUT

    output = xmlpp(<<~"OUTPUT")
    #{BLANK_HDR}
<sections/>
</rsd-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :ribose, header_footer: true)))).to be_equivalent_to output
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r{jquery\.min\.js})
    expect(html).to match(%r{Source Sans Pro})
  end

    it "cross-references sections" do
      expect(xmlpp(IsoDoc::Ribose::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       <clause id="C1" inline-header="false" obligation="informative">Text</clause>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <terms id="H" obligation="normative"><title>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
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
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>
      </sections><annex id="P" inline-header="false" obligation="normative">
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
       </annex><bibliography><references id="R" obligation="informative" normative="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </rsd-standard>
    INPUT
    <rsd-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
         <preface>
           <foreword obligation='informative'>
             <title>Foreword</title>
             <p id='A'>
               This is a preamble
               <xref target='C'>Introduction Subsection</xref>
               <xref target='C1'>Introduction, 2</xref>
               <xref target='D'>Clause 1</xref>
               <xref target='H'>Clause 3</xref>
               <xref target='I'>3.1</xref>
               <xref target='J'>3.1.1</xref>
               <xref target='K'>3.2</xref>
               <xref target='L'>Clause 4</xref>
               <xref target='M'>Clause 5</xref>
               <xref target='N'>5.1</xref>
               <xref target='O'>5.2</xref>
               <xref target='P'>Annex A</xref>
               <xref target='Q'>Annex A.1</xref>
               <xref target='Q1'>Annex A.1.1</xref>
               <xref target='Q2'>[Q2]</xref>
               <xref target='R'>Clause 2</xref>
             </p>
           </foreword>
           <introduction id='B' obligation='informative'>
             <title>Introduction</title>
             <clause id='C' inline-header='false' obligation='informative'>
               <title depth='2'>Introduction Subsection</title>
             </clause>
             <clause id='C1' inline-header='false' obligation='informative'>Text</clause>
           </introduction>
         </preface>
         <sections>
           <clause id='D' obligation='normative' type='scope'>
             <title depth='1'>
               1.
               <tab/>
               Scope
             </title>
             <p id='E'>Text</p>
           </clause>
           <terms id='H' obligation='normative'>
             <title depth='1'>
               3.
               <tab/>
               Terms, definitions, symbols and abbreviated terms
             </title>
             <terms id='I' obligation='normative'>
               <title depth='2'>
                 3.1.
                 <tab/>
                 Normal Terms
               </title>
               <term id='J'>
                 <name>3.1.1.</name>
                 <preferred>Term2</preferred>
               </term>
             </terms>
             <definitions id='K'>
               <title>3.2.</title>
               <dl>
                 <dt>Symbol</dt>
                 <dd>Definition</dd>
               </dl>
             </definitions>
           </terms>
           <definitions id='L'>
             <title>4.</title>
             <dl>
               <dt>Symbol</dt>
               <dd>Definition</dd>
             </dl>
           </definitions>
           <clause id='M' inline-header='false' obligation='normative'>
             <title depth='1'>
               5.
               <tab/>
               Clause 4
             </title>
             <clause id='N' inline-header='false' obligation='normative'>
               <title depth='2'>
                 5.1.
                 <tab/>
                 Introduction
               </title>
             </clause>
             <clause id='O' inline-header='false' obligation='normative'>
               <title depth='2'>
                 5.2.
                 <tab/>
                 Clause 4.2
               </title>
             </clause>
           </clause>
         </sections>
         <annex id='P' inline-header='false' obligation='normative'>
           <title>
             Annex A
             <br/>
             (normative)
             <br/>
             <br/>
             Annex
           </title>
           <clause id='Q' inline-header='false' obligation='normative'>
             <title depth='2'>
               A.1.
               <tab/>
               Annex A.1
             </title>
             <clause id='Q1' inline-header='false' obligation='normative'>
               <title depth='3'>
                 A.1.1.
                 <tab/>
                 Annex A.1a
               </title>
             </clause>
           </clause>
           <appendix id='Q2' inline-header='false' obligation='normative'>
             <title>An Appendix</title>
           </appendix>
         </annex>
         <bibliography>
           <references id='R' obligation='informative' normative='true'>
             <title depth='1'>
               2.
               <tab/>
               Normative References
             </title>
           </references>
           <clause id='S' obligation='informative'>
             <title depth='1'>Bibliography</title>
             <references id='T' obligation='informative' normative='false'>
               <title depth='2'>Bibliography Subsection</title>
             </references>
           </clause>
         </bibliography>
       </rsd-standard>
    OUTPUT
  end


end
