require 'spec_helper'

describe DailyGroupingUpdater do
  subject { described_class.new }

  describe "#perform" do
    let(:acknowledged_grouping) { groupings :acknowledged }
    let(:resolved_grouping) { groupings :resolved }
    let(:app_name) { :app1 }

    context "within 15 days of the latest wat" do

      it "should not resolve the acknowledged wats" do
        expect_any_instance_of(Grouping).not_to receive(:resolve!)
        subject.perform(app_name: app_name)
      end
    end

    context "more than 15 days after the latest wat" do
      before do
        acknowledged_grouping.update! latest_wat_at: 20.days.ago
        resolved_grouping.update! latest_wat_at: 20.days.ago
      end

      it "should resolve the acknowledged wats of a given app and set the system account" do
        expect_any_instance_of(Grouping).to receive(:resolve!).once
        expect(PaperTrail).to receive(:whodunnit=)
        subject.perform(app_name: app_name)
      end

      it "should not resolve the acknowledged wats of a different app" do
        expect_any_instance_of(Grouping).not_to receive(:resolve!)
        subject.perform(app_name: "non-existent-app")
      end
    end
  end
end
