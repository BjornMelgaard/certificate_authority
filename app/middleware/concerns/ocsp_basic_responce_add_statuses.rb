module OcspBasicResponceAddStatuses
  THIS_UPDATE = -1800
  NEXT_UPDATE = 3600

  def add_statuses(from_request, to_basic_responce)
    certificates = get_certificates(from_request)
    certids_with_certificates = from_request.certid.zip(certificates)

    certids_with_certificates.each do |cid, cert|
      add_status(to_basic_responce, cid, cert)
    end
  end

  private

  def get_certificates(request)
    serials = request.certid.map(&:serial).map(&:to_i)
    Certificate.where(serial: serials)
  end

  def add_status(basic_responce, cid, cert)
    status = cert&.status || OpenSSL::OCSP::V_CERTSTATUS_UNKNOWN
    reason = cert&.reason || OpenSSL::OCSP::REVOKED_STATUS_UNSPECIFIED
    revocation_time = cert&.revoked_at&.to_i || 0
    basic_responce.add_status(cid,
                              status,
                              reason,
                              revocation_time,
                              THIS_UPDATE,
                              NEXT_UPDATE,
                              nil)
  end
end
