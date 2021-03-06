require_relative "../../spec_helper"

describe "Weekly Collector Module" do

  class WeeklyDummy < GoogleAnalytics::Config::Base
    include GoogleAnalytics::Config::WeeklyCollector

    attr_reader :start_at, :end_at
  end

  it "should have a response type of WeeklyResponse" do
    weekly_config = WeeklyDummy.last_before(Date.new(2012, 8, 9))

    weekly_config.response_type.should be(GoogleAnalytics::WeeklyResponse)
  end

  it "should create a range for the last week" do
    on_tuesday = WeeklyDummy.last_before(Date.new(2012, 8, 9))

    on_tuesday.start_at.should eql(Date.new(2012, 7, 29))
    on_tuesday.end_at.should eql(Date.new(2012, 8, 4))
  end

  it "should go back to last saturday, if passed date is a saturday" do
    on_saturday = WeeklyDummy.last_before(Date.new(2012, 3, 17))

    on_saturday.start_at.should eql(Date.new(2012, 3, 4))
    on_saturday.end_at.should eql(Date.new(2012, 3, 10))
  end

  it "should use exact week when given" do
    one_week = WeeklyDummy.all_within(Date.new(2012, 8, 5), Date.new(2012, 8, 12))

    one_week.should be_an(Array)
    one_week = one_week.first

    one_week.start_at.should == Date.new(2012, 8, 5)
    one_week.end_at.should == Date.new(2012, 8, 11)
  end

  it "should not include the week were the end date is in" do
    one_week = WeeklyDummy.all_within(Date.new(2012, 8, 5), Date.new(2012, 8, 18)).first

    one_week.start_at.should == Date.new(2012, 8, 5)
    one_week.end_at.should == Date.new(2012, 8, 11)
  end

  it "should include the whole week if the start date is a saturday" do
    one_week = WeeklyDummy.all_within(Date.new(2012, 8, 4), Date.new(2012, 8, 12)).last

    one_week.start_at.should == Date.new(2012, 7, 29)
    one_week.end_at.should == Date.new(2012, 8, 4)
  end

  it "should include the whole week if the start date is a wednesday" do
    one_week = WeeklyDummy.all_within(Date.new(2012, 8, 1), Date.new(2012, 8, 12)).last

    one_week.start_at.should == Date.new(2012, 7, 29)
    one_week.end_at.should == Date.new(2012, 8, 4)
  end


  it "should have multiple weeks for longer periods" do
    week_one, week_two = *WeeklyDummy.all_within(Date.new(2012, 8, 1), Date.new(2012, 8, 12))

    week_one.start_at.should == Date.new(2012, 8, 5)
    week_one.end_at.should == Date.new(2012, 8, 11)

    week_two.start_at.should == Date.new(2012, 7, 29)
    week_two.end_at.should == Date.new(2012, 8, 4)
  end

  it "should have a 6 week period on 2012-01-25 to 2012-03-04" do
    weeks = WeeklyDummy.all_within(Date.new(2012, 1, 25), Date.new(2012, 3, 4))

    weeks.should have(6).items

    weeks[0].start_at.should == Date.new(2012, 2, 26)
    weeks[1].start_at.should == Date.new(2012, 2, 19)
    weeks[2].start_at.should == Date.new(2012, 2, 12)
    weeks[3].start_at.should == Date.new(2012, 2, 5)
    weeks[4].start_at.should == Date.new(2012, 1, 29)
    weeks[5].start_at.should == Date.new(2012, 1, 22)
  end

  [7, 8, 13].each { |day_of_month|
    single_day = Date.new(2012, 10, day_of_month)
    weekday_name = single_day.strftime("%A")
    it "should always look up data for 1 previous full week period, when given single day: #{weekday_name} #{single_day} as an argument" do
      weeks = WeeklyDummy.all_within(single_day, single_day)

      weeks.should have(1).items

      weeks[0].start_at.should == Date.new(2012, 9, 30)
      weeks[0].end_at.should == Date.new(2012, 10, 6)
    end
  }

  it "should include week previous to the one contained by a provided range if this range is less than 7 days and ends with Saturday" do
    weeks = WeeklyDummy.all_within(Date.new(2012, 10, 7), Date.new(2012, 10, 13))

    weeks.should have(1).items

    weeks[0].start_at.should == Date.new(2012, 9, 30)
    weeks[0].end_at.should == Date.new(2012, 10, 6)
  end


  it "should include week defined by a provided range if it's exactly 7 days and ends with Sunday" do
    weeks = WeeklyDummy.all_within(Date.new(2012, 10, 7), Date.new(2012, 10, 14))

    weeks.should have(1).items

    weeks[0].start_at.should == Date.new(2012, 10, 7)
    weeks[0].end_at.should == Date.new(2012, 10, 13)
  end
end