module HomePage
  class CertificateDecorator < SimpleDelegator
    include ViewHelpers

    def self.for_collection(certs)
      certs.map { |cert| new(cert) }
    end

    def name
      subject.common_name
    end

    def date
      not_before.strftime('%m/%d/%Y at %H:%M')
    end

    def revoke_button
      css_class = 'button is-danger is-pulled-right'
      css_class += ' is-disabled' if revoked?

      name = revoked? ? 'Revoked' : 'Revoke'

      url = urls.api_v1_certificate_revoke_path(serial: serial)
      h.content_tag :button,
                    name,
                    class: css_class,
                    data: { 'revoke-button': url }
    end
  end
end
