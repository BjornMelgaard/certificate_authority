describe 'certificate_authority:create_root' do
  include_context 'rake'

  it 'create cert' do
    subject.invoke
    file = Rails.root.join('public', 'root-ca.crt')
    expect(file).to be_an_existing_file
  end
end
