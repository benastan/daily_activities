require 'spec_helper'

describe 'daily activities', js: true do
  include Capybara::DSL

  specify do
    visit '/'

    click_on 'Create Activity'
    expect(page).to have_content 'Activity name is blank.'
    
    fill_in 'New Activity', with: 'Went Running'
    click_on 'Create Activity'
    check 'Went Running'
    visit '/'
    wait_for_ajax
    expect(find_field('Went Running')).to be_checked

    Timecop.freeze(Date.today + 10) do
      visit '/'
      expect(find_field('Went Running')).to_not be_checked
    end

    visit '/'
    uncheck 'Went Running'
    visit '/'
    expect(find_field('Went Running')).to_not be_checked
  end
end
