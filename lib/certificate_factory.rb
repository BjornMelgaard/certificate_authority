class CertificateFactory
  class RequiredAttribute < ::StandardError
    def initialize(attribute)
      super "#{attribute} attribute is required"
    end
  end

  def self.from_csr(role, csr)
    new(role).tap do |generator|
      generator.subject    = csr.subject
      generator.public_key = csr.public_key
    end
  end

  def initialize(role)
    @role = role
    @certificate = OpenSSL::X509::Certificate.new
    cert_set_defaults
  end

  attr_reader :certificate, :private_key
  delegate :subject=, :public_key=, to: :certificate

  def sign_by!(parent_cert, parent_key)
    @certificate.issuer = parent_cert.subject
    generate_key_material unless certificate_has_public_key? # can be added from_csr
    add_extensions(parent_cert)
    validate!
    sign(parent_key)
  end

  def selfsign!
    @certificate.issuer = @certificate.subject
    generate_key_material # we dont expect that from_csr can be selfsigned
    add_extensions
    validate!
    sign
  end

  private

  def generate_key_material
    @private_key = OpenSSL::PKey::RSA.new(2048)
    @certificate.public_key = @private_key.public_key
  end

  def certificate_has_public_key?
    @certificate.public_key
  rescue OpenSSL::X509::CertificateError
    false
  end

  def validate!
    %i(version not_before not_after serial)
      .each { |attr| raise RequiredAttribute, attr unless @certificate.send(attr) }
    %i(subject issuer)
      .each { |dn| raise RequiredAttribute, dn if @certificate.send(dn).to_s.blank? }
    raise RequiredAttribute, :extensions unless @certificate.extensions.any?
    raise RequiredAttribute, :public_key unless certificate_has_public_key?
  end

  def cert_set_defaults
    @certificate.version = 2
    @certificate.serial = SecureRandom.random_number(2**128 - 1)
    @certificate.not_before = Time.zone.now
    @certificate.not_after = @certificate.not_before.advance(years: 1)
  end

  def add_extensions(issuer_cert = nil)
    extensions = ExtensionsHolder.extensions_for(@role)

    ef = OpenSSL::X509::ExtensionFactory.new # why do we need factory?
    ef.subject_certificate = @certificate
    ef.issuer_certificate = issuer_cert || @certificate

    extensions.critical.each do |oid, value|
      @certificate.add_extension ef.create_extension(oid, value, true)
    end

    extensions.non_critical.each do |oid, value|
      @certificate.add_extension ef.create_extension(oid, value, false)
    end
  end

  def sign(parent_key = nil)
    @certificate.sign(parent_key || @private_key, OpenSSL::Digest::SHA256.new)
  end
end
