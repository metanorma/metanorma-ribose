# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Metanorma::Ribose::Document namespace" do
  describe "canonical namespace" do
    it "exposes Metanorma::Ribose::Document as a Module" do
      expect(Metanorma::Ribose::Document).to be_a(Module)
    end

    it "exposes Root with the canonical name" do
      expect(Metanorma::Ribose::Document::Root.name)
        .to eq("Metanorma::Ribose::Document::Root")
    end

    it "Root is a lutaml Serializable" do
      expect(Metanorma::Ribose::Document::Root < Lutaml::Model::Serializable).to be(true)
    end
  end

  describe "backwards-compat alias" do
    it "Metanorma::RiboseDocument aliases to the new namespace" do
      expect(Metanorma::RiboseDocument).to eq(Metanorma::Ribose::Document)
    end

    it "the alias preserves class identity" do
      expect(Metanorma::RiboseDocument::Root.equal?(
               Metanorma::Ribose::Document::Root)).to be(true)
    end
  end

  describe "parent namespace" do
    it "Metanorma::Standoc::Document is available" do
      expect(Metanorma::Standoc::Document).to be_a(Module)
    end

    it "Metanorma::StandardDocument alias is available" do
      expect(Metanorma::StandardDocument).to eq(Metanorma::Standoc::Document)
    end
  end
end
