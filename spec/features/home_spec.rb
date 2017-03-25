feature 'Home page:' do
  let!(:certificates) { create_list :certificate, 4 }

  it 'shows all certificates' do
    visit root_path
    expect(page).to have_current_path root_path
    require 'pry'; ::Kernel.binding.pry;

  end
end
