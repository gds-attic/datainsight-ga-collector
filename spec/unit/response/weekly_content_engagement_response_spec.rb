require_relative "../../spec_helper"

include GoogleAnalytics
describe "weekly content/engagement response" do

  def message_for_format format
    @response.messages.find do |msg|
      msg[:payload][:value][:format] == format
    end
  end

  describe "without year switch" do

    before(:each) do
      response_as_hash = load_json("weekly_content_engagement_response.json")
      @response = WeeklyContentEngagementResponse.new([response_as_hash], GoogleAnalytics::Config::WeeklyContentEngagement)
    end

    it "should have an array of messages" do
      @response.messages.should be_an(Array)
      @response.messages.should have(13).items
    end

    it "should have an envelope and a payload" do
      @response.messages.first[:envelope].should be_a(Hash)
      @response.messages.first[:envelope][:collected_at].should be_a(DateTime)
      @response.messages.first[:envelope][:collector].should eql("Google Analytics")
      @response.messages.first[:payload].should be_a(Hash)
    end

    it "should have start_at, end_at and site data" do
      message_payload = @response.messages.first[:payload]
      message_payload[:start_at].should eql("2012-01-09T00:00:00+00:00")
      message_payload[:end_at].should eql("2012-01-16T00:00:00+00:00")
      message_payload[:value][:site].should eql("govuk")
    end

    it "should have entries and successes for guide" do
      # There are no success events on answer
      message_payload = message_for_format("guide")[:payload]
      message_payload[:value][:entries].should eql(11882)
      message_payload[:value][:successes].should eql(10148)
    end

    it "should have entries and 0 successes for answer" do
      message_payload = message_for_format("answer")[:payload]
      message_payload[:value][:entries].should eql(8939)
      message_payload[:value][:successes].should eql(0)
    end

  end

  describe "response with no results" do
    before(:each) do
      response_as_hash = load_json("weekly_content_engagement_response_no_results.json")
      @response = WeeklyContentEngagementResponse.new([response_as_hash], GoogleAnalytics::Config::WeeklyContentEngagement)
    end

    it "should create no messages" do
      @response.messages.should be_an(Array)
      @response.messages.should be_empty
    end
  end
end