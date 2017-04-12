every 12.hours do
  runner 'CertificateCleanupJob.perform_now'
end
