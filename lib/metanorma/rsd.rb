require "metanorma"
require "metanorma-acme"
require "metanorma/rsd/processor"

module Metanorma
  module Rsd
    ORGANIZATION_NAME_SHORT = 'Ribose'.freeze
    ORGANIZATION_NAME_LONG = 'Ribose'.freeze
    DOCUMENT_NAMESPACE = 'https://open.ribose.com/standards/rsd'.freeze

    class Configuration < Metanorma::Acme::Configuration
      def initialize(*args)
        self.organization_name_short ||= ORGANIZATION_NAME_SHORT
        self.organization_name_long ||= ORGANIZATION_NAME_LONG
        self.document_namespace ||= DOCUMENT_NAMESPACE
        isodoc_html_folder ||= File.join(File.expand_path('../isodoc', __dir__),
                                          'rsd',
                                          'html')
        self.wordstylesheet ||= File.join(isodoc_html_folder, 'wordstyle.scss')
        self.standardstylesheet ||= File.join(isodoc_html_folder, 'rsd.scss')
        self.header ||= File.join(isodoc_html_folder, 'header.html')
        self.wordcoverpage ||= File.join(isodoc_html_folder,
                                        'word_rsd_titlepage.html')
        self.wordintropage ||= File.join(isodoc_html_folder,
                                        'word_rsd_intro.html')
        self.htmlstylesheet ||= File.join(isodoc_html_folder,
                                          'htmlstyle.scss')
        self.htmlcoverpage ||= File.join(isodoc_html_folder,
                                        'html_rsd_titlepage.html')
        self.htmlintropage ||= File.join(isodoc_html_folder,
                                        'html_rsd_intro.html')
        self.scripts ||= File.join(isodoc_html_folder, 'scripts.html')
        self.scripts_pdf ||= File.join(isodoc_html_folder, 'scripts.pdf.html')
        self.logo_path ||= File.join(isodoc_html_folder, 'logo.svg')
        self.xml_root_tag ||= 'rsd-standard'
        rng_folder ||= File.join(File.expand_path('asciidoctor', __dir__), 'rsd')
        self.validate_rng_file ||= File.join(rng_folder, 'rsd.rng')
        super
      end
    end

    class << self
      extend Forwardable

      attr_accessor :configuration

      Configuration::CONFIG_ATTRS.each do |attr_name|
        def_delegator :@configuration, attr_name
      end

      def configure
        self.configuration ||= Configuration.new
        yield(configuration)
      end
    end

    configure {}
  end
end
Metanorma::Registry.instance.register(Metanorma::Rsd::Processor)
