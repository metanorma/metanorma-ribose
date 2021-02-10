require "spec_helper"

RSpec.describe Asciidoctor::Ribose do
  context "when xref_error.adoc compilation" do
    it "generates error file" do
      File.write("xref_error.adoc", <<~"CONTENT")
        = X
        A

        == Clause

        <<a,b>>
      CONTENT

      expect do
        Metanorma::Compile
          .new
          .compile("xref_error.adoc", type: "ribose", no_install_fonts: true)
      end.to(change { File.exist?("xref_error.err") }
              .from(false).to(true))
    end
  end
end
