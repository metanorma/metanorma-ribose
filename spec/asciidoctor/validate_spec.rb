require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Rsd do
  it "Warns of illegal doctype" do
    input = <<~"INPUT"
    = Document title
    Author
    :docfile: test.adoc
    :nodoc:
    :no-isobib:
    :doctype: pizza

    text
    INPUT
    expect { Asciidoctor.convert(input, backend: :rsd, header_footer: true) }.to output(/pizza is not a legal document type/).to_stderr
  end

  it "Warns of illegal status" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :rsd, header_footer: true) }.to output(/pizza is not a recognised status/).to_stderr
    = Document title
    Author
    :docfile: test.adoc
    :nodoc:
    :no-isobib:
    :status: pizza

    text
    INPUT
  end
end

