# frozen_string_literal: true

require "metanorma/standoc"
require "metanorma/iso/document/models"
module Metanorma
  module Ribose
  end
end

module Metanorma
  module Ribose::Document
    autoload :Metadata, "metanorma/ribose/document/metadata"
    autoload :Root, "metanorma/ribose/document/root"
  end
end

module Metanorma
  existing = defined?(Metanorma::RiboseDocument) && Metanorma::RiboseDocument
  if !existing.equal?(Metanorma::Ribose::Document)
    Metanorma.send(:remove_const, :RiboseDocument) if existing
    RiboseDocument = Metanorma::Ribose::Document
  end
end

# OCP adoption: ONE registration in the metanorma-core flavor table
require "metanorma-core"

Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
  name: :ribose,
  gem: "metanorma-ribose",
  model_root: Metanorma::Ribose::Document::Root,
  pubid_module: nil,
  renderers: { html: lambda do |_document, **_options|
    Metanorma::Html::StandardRenderer
  end },
))
