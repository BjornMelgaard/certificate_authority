module HomePage
  class CertificateDecorator < SimpleDelegator
    include ViewHelpers

    def self.for_collection(certs)
      certs.map { |cert| new(cert) }
    end

    def name
      cert.subject.common_name
    end

    def date
      cert.not_before.strftime('%m/%d/%Y at %H:%M')
    end

    def revoke_button
      css_class = 'button is-danger is-pulled-right'
      css_class += ' is-disabled' if revoked?

      name = revoked? ? 'Revoked' : 'Revoke'

      h.content_tag :button,
                    name,
                    class: css_class,
                    data: { 'revoke-button': cert.serial.to_s }
    end
  end
end
