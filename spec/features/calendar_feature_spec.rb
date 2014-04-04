require 'spec_helper'

describe "Viewing a calendar", :feature do
  before { Almanac.reset! }

  it "displays all upcoming events" do
    Almanac.config.add_events [
      { title: "Hogswatch" },
      { title: "Soul Cake Tuesday" },
      { title: "Eve of Small Gods" },
    ]

    get "/"

    expect(last_response).to have_event_on_page("Hogswatch")
    expect(last_response).to have_event_on_page("Soul Cake Tuesday")
    expect(last_response).to have_event_on_page("Eve of Small Gods")
  end

  it "displays events from an iCal feed" do
    Almanac.config.add_ical_feed "https://www.google.com/calendar/ical/61s2re9bfk01abmla4d17tojuo%40group.calendar.google.com/public/basic.ics"
    
    Timecop.freeze(2014, 4, 3) do
      VCR.use_cassette('google_calendar') do
        get "/"
      end
    end

    expect(last_response).to have_event_on_page("Ruby Meetup @catalyst - Tanks! Guns!")
    expect(last_response).to have_event_on_page("The Foundation")
    expect(last_response).to have_event_on_page("WikiHouse/NZ weekly meet-up")
    expect(last_response).to have_event_on_page("Christchurch Python Meetup")
    expect(last_response).to have_event_on_page("Coffee & Jam")
  end
end