class CertificateCleanupJob < ApplicationJob
  queue_as :low_priority

  def perform
    Certificate.where('updated_at < ?', 1.day.ago).destroy_all
  end
end
