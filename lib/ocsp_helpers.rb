module OcspHelpers
  class << self
    def ocsp_domain
      "http://#{ENV['OCSP_HOST']}"
    end

    def ocsp_host
      ENV['OCSP_HOST']
    end
  end
end
