require 'spec_helper'

describe TrackersController, type: :controller do
  context "when logged in" do
    let(:watcher) { watchers :default_with_tracker }

    before do
      login watcher
      @request.env['HTTP_REFERER'] = '/something'
    end

    describe "POST #create" do
      let(:grouping) { groupings(:grouping1) }
      let(:tracker) {{ grouping_id: grouping.id, tracker_project: "Blue" }}
      subject { post :create, tracker: tracker }

      it "updates grouping with the new story id" do
        expect { subject }.to change { grouping.reload.pivotal_tracker_story_id }.from(nil)
      end

      context "when a project wants language labels" do
        it "shows language labels" do
          expect_any_instance_of(Grouping).to receive(:language)
          subject
        end
      end

      context "when a project does not want langauge labels" do
        let(:tracker) {{ grouping_id: grouping.id, tracker_project: "Rainbow" }}

        it "does not use the language to label the story for projects that do not want it" do
          expect_any_instance_of(Grouping).not_to receive(:language)
          subject
        end
      end
    end
  end
end
