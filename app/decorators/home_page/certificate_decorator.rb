module HomePage
  class CertificateDecorator < SimpleDelegator
    def self.for_collection(certs)
      certs.map { |cert| new(cert) }
    end

    def name
      cert.subject.to_s
    end

    def date
      cert.not_before
    end
  end
end
