module HomePage
  class HomePresenter < Rectify::Presenter
    def initialize
      @certificates = HomePage::CertificateDecorator.for_collection(Certificate.all)
    end

    attr_reader :certificates
  end
end
