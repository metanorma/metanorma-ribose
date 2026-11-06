require "spec_helper"

RSpec.describe Metanorma::Ribose do
  it "validates document against Metanorma XML schema" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = A
      X
      :docfile: test.adoc
      :no-pdf:

      [align=mid-air]
      Para
    INPUT
    expect(File.read("test.err.html"))
      .to include('element "sections" incomplete; expected element "clause"')
  end
end
