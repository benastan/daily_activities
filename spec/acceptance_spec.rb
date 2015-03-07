require 'spec_helper'

describe 'daily activities', js: true do
  include Capybara::DSL

  around do |example|
    Timecop.travel(Date.new(2014, 01, 01)) { example.run }
  end

  specify do
    visit '/'

    click_on 'Create Activity'
    expect(page).to have_content 'Activity name is blank.'
    
    fill_in 'New Activity', with: 'Went Running'
    click_on 'Create Activity'
    check 'Went Running'
    wait_for_ajax
    visit '/'
    expect(find_field('Went Running')).to be_checked

    Timecop.travel(Date.today + 10) do
      visit '/'
      expect(find_field('Went Running')).to_not be_checked
      check 'Went Running'
    end

    Timecop.travel(Date.today + 20) do
      visit '/'
      click_on 'History'
      click_on '2014-01-01'
      expect(page).to have_content 'Went Running'
    end

    visit '/'
    uncheck 'Went Running'
    wait_for_ajax
    visit '/'
    expect(find_field('Went Running')).to_not be_checked
  end
end
