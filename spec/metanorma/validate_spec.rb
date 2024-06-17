require "spec_helper"

RSpec.describe Metanorma::Ribose do
  context "when xref_error.adoc compilation" do
    it "generates error file" do
      FileUtils.rm_rf "xref_error.err.html"
      File.write("xref_error.adoc", <<~"CONTENT")
        = X
        A
        :no-pdf:

        == Clause

        <<a,b>>
      CONTENT

      expect do
        Metanorma::Compile
          .new
          .compile("xref_error.adoc", type: "ribose", install_fonts: false)
      end.to(change { File.exist?("xref_error.err.html") }
              .from(false).to(true))
    end
  end
end
