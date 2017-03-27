feature 'Home page:' do
  let!(:certificates) { create_list :certificate, 4 }
  let(:valid_cert_path) { Rails.root.join('spec', 'fixtures', 'mysigningrequest.csr') }

  before do
    clear_downloads
    visit root_path
    expect(page).to have_current_path root_path
  end

  it 'can upload cert' do
    expect do
      uploader = find '#csr_uploader', visible: false
      uploader.set(valid_cert_path)
      page.execute_script %{
        window.uploadFiles()
      }
      expect(page).to have_content 'Sertificate was created successfully'
      expect(downloads.size).to eq 1
    end.to change { Certificate.count }.by(1)
  end

  it 'can revoke' do
    cert = certificates.sample
    button = find("button[data-revoke-button=\"#{cert.serial}\"]")
    button.click
    expect(button).to have_content 'Revoked'
    expect(cert.reload.status).not_to eq 0
  end
end
