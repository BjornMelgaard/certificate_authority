module OpensslHelpers
  def get_ocsp_url(cert)
    extension_by_oid(cert, 'authorityInfoAccess')
      .value
      .split("\n")
      .last
  end

  def extension_by_oid(cert, oid)
    cert.extensions.find { |ext| ext.oid == oid }
  end
end

RSpec.configure do |config|
  config.include OpensslHelpers
end

