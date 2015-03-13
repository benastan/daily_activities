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

    within first('.list-group-item', text: 'Went Running') do
      click_on 'edit'
    end

    fill_in 'Activity Name', with: 'Go Running'
    click_on 'Update Activity'
    expect(page).to have_content 'Go Running'

    Timecop.travel(Date.today + 20) do
      visit '/'
      click_on 'History'
      click_on '2014-01-01'
      expect(page).to have_content '2014-01-01'
      expect(page).to have_content 'Go Running'
    end

    visit '/'
    uncheck 'Go Running'
    wait_for_ajax
    visit '/'
    expect(find_field('Go Running')).to_not be_checked

    click_on 'Yesterday'
    check 'Go Running'
    wait_for_ajax
    click_on 'Today'
    expect(find_field('Go Running')).to_not be_checked
    
    click_on 'History'
    click_on '2013-12-31'
    expect(page).to have_content '2013-12-31'
    expect(page).to have_content 'Go Running'
  end
end
