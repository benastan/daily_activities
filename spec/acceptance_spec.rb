require 'spec_helper'

describe 'daily activities', js: true do
  include Capybara::DSL

  around do |example|
    Timecop.travel(Date.new(2014, 01, 01)) { example.run }
  end

  let(:jane) do
    {
      'id' => '12331',
      'name' => {
        'givenName' => 'Jane'
      },
      'emails' => [
        { 'value' => 'jane@example.com' }
      ]
    }
  end

  let(:joe) do
    {
      'id' => '91234',
      'name' => {
        'givenName' => 'Joe'
      },
      'emails' => [
        { 'value' => 'joe@example.com' }
      ]
    }
  end

  def sign_in(user)
    allow_any_instance_of(DailyActivities::Application).to receive(:current_user).and_call_original
    allow_any_instance_of(DailyActivities::Application).to receive(:current_user).and_return(user)
  end

  specify do
    sign_in(jane)

    visit '/'

    click_on 'Create Activity'
    expect(page).to have_content 'Required fields are missing'
    
    fill_in 'New Activity', with: 'Went Running'
    click_on 'Create Activity'

    fill_in 'New Activity', with: 'Slept well'
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
      expect(page).to have_content 'Wednesday, January 01, 2014'
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
    
    click_on 'Previous Day'
    check 'Slept well'
    wait_for_ajax
    click_on 'Next Day'
    expect(find_field('Slept well')).to_not be_checked
    
    click_on 'Today'
    expect(find_field('Go Running')).to_not be_checked

    click_on 'History'
    click_on '2013-12-31'
    expect(page).to have_content 'Tuesday, December 31, 2013'
    expect(page).to have_content 'Go Running'
    expect(page).to_not have_content 'Slept well'

    click_on 'Revise'
    expect(page).to have_content 'Tuesday, December 31, 2013'
    expect(find_field('Go Running')).to be_checked

    click_on 'History'
    click_on '2013-12-30'
    expect(page).to have_content 'Monday, December 30, 2013'
    expect(page).to_not have_content 'Go Running'
    expect(page).to have_content 'Slept well'

    sign_in(joe)
    visit '/'
    expect(page).to_not have_content 'Slept well'
  end
end
