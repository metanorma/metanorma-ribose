require "spec_helper"

RSpec.describe Metanorma::Ribose do
  it "has a version number" do
    expect(Metanorma::Ribose::VERSION).not_to be nil
  end

  describe "#configuration" do
    it "has `configuration` attribute accessable" do
      expect(Metanorma::Ribose.configuration)
        .to(be_instance_of(Metanorma::Ribose::Configuration))
    end

    context "default attributes" do
      subject(:config) { Metanorma::Ribose.configuration }
      let(:default_organization_name_short) { "Ribose" }
      let(:default_organization_name_long) { "Ribose Asia Limited" }

      it "sets default atrributes" do
        expect(config.organization_name_short)
          .to(eq(default_organization_name_short))
        expect(config.organization_name_long)
          .to(eq(default_organization_name_long))
      end
    end

    context "attribute setters" do
      subject(:config) { Metanorma::Ribose.configuration }
      let(:organization_name_short) { "Test" }
      let(:organization_name_long) { "Test Corp." }

      it "sets atrributes" do
        Metanorma::Ribose.configure do |config|
          config.organization_name_short = organization_name_short
          config.organization_name_long = organization_name_long
        end
        expect(config.organization_name_short).to eq(organization_name_short)
        expect(config.organization_name_long).to eq(organization_name_long)
      end
    end
  end
end
