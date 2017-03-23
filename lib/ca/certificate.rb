require_relative 'concerns/inspectable'

module CA
  class Certificate < SimpleDelegator
    include Inspectable

    attr_accessor :parent, :private_key

    def self.from_csr(csr)
      new.tap do |cert|
        cert.subject    = csr.subject
        cert.public_key = csr.public_key
      end
    end

    def self.from_existing(cert, private_key)
      new(cert).tap { |decorated| decorated.private_key = private_key }
    end

    def initialize(cert = nil)
      return super(cert) if cert
      super OpenSSL::X509::Certificate.new
      __getobj__.version = 2
      __getobj__.serial = SecureRandom.random_number(2**128 - 1)
      __getobj__.not_before = Time.zone.now
      __getobj__.not_after = __getobj__.not_before.advance(years: 1)
    end

    def selfsigned?
      @parent.nil?
    end

    def sign!
      validate!
      __getobj__.issuer = selfsigned? ? __getobj__.subject : parent.subject
      __getobj__.sign(signing_key, OpenSSL::Digest::SHA256.new)
    end

    def signing_key
      selfsigned? ? private_key : parent.private_key
    end

    def generate_key_material
      @private_key = OpenSSL::PKey::RSA.new(2048)
      __getobj__.public_key = @private_key.public_key
    end

    def extensions=(extensions)
      ef = OpenSSL::X509::ExtensionFactory.new # why do we need factory?
      ef.subject_certificate = __getobj__
      ef.issuer_certificate = selfsigned? ? __getobj__ : parent.__getobj__

      extensions.critical.each do |oid, value|
        __getobj__.add_extension ef.create_extension(oid, value, true)
      end

      extensions.non_critical.each do |oid, value|
        __getobj__.add_extension ef.create_extension(oid, value, false)
      end
    end

    private

    def validate!
      obj_attrs = %i(subject issuer public_key version not_before not_after serial)
      obj_attrs.each { |attr| raise unless __getobj__.send(attr) }
      raise unless __getobj__.extensions.any?
      raise unless signing_key
    end
  end
end
