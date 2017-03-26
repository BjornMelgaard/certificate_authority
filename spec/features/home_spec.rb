feature 'Home page:' do
  let!(:certificates) { create_list :certificate, 4 }

  before do
    visit root_path
    expect(page).to have_current_path root_path
  end

  it 'can revoke' do
    # require 'pry'; ::Kernel.binding.pry;
  end
end
