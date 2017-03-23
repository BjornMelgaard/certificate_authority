module OpensslShim
  class Certificate < SimpleDelegator
    def initialize(role, parent: nil)
      @role = role
      @parent = parent

      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = SecureRandom.random_number(2**128 - 1)
      cert.not_before = Time.zone.now
      cert.not_after = cert.not_before.advance(years: 1)

      super(cert)

      add_extensions
    end

    attr_reader :private_key, :role

    def generate_key_material
      @private_key = OpenSSL::PKey::RSA.new(2048)
      @public_key = @private_key.public_key
    end

    def sign!
      raise unless __getobj__.subject
      raise if !@parent.nil? && !@parent.is_a?(self.class)
      raise unless @public_key

      signing_key = @parent&.private_key || @private_key
      raise unless signing_key

      __getobj__.issuer = @parent&.subject || __getobj__.subject
      __getobj__.sign(signing_key, OpenSSL::Digest::SHA256.new)
    end

    def inspect
      <<~HEREDOC
        Certificate: role=#{role},
                     subject=#{subject},
                     issuer=#{issuer},
                     private_key #{'not ' unless @private_key}exists
                     extensions=#{extensions.map(&:to_s)}
      HEREDOC
    end

    private

    def add_extensions
      extensions = ExtensionsHolder.extensions_for(role)

      ef = OpenSSL::X509::ExtensionFactory.new # why do we need factory?
      ef.subject_certificate = __getobj__
      ef.issuer_certificate = @parent&.__getobj__ || __getobj__

      extensions.critical.each do |oid, value|
        __getobj__.add_extension ef.create_extension(oid, value, true)
      end

      extensions.non_critical.each do |oid, value|
        __getobj__.add_extension ef.create_extension(oid, value, false)
      end
    end
  end
end
