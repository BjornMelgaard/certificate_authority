module HomePage
  class HomePresenter < Rectify::Presenter
    def initialize
      certs = Certificate.order(created_at: :desc).limit(50)
      @certificates = HomePage::CertificateDecorator.for_collection(certs)
    end

    attr_reader :certificates
  end
end
