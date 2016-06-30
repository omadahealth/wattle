class DailyGroupingUpdater
  include Sidekiq::Worker

  def initialize
    @system_account = Watcher.find_by_email("kairos-robot@omadahealth.com")
    PaperTrail.whodunnit = @system_account
  end

  def perform(app_name: nil)
    raise "An app_name must be specified." unless app_name.present?

    groupings = Grouping.app_name(app_name).where(state: :acknowledged).where("latest_wat_at <= ?", 15.days.ago)
    groupings.each do |grouping|
      grouping.resolve!

      accept_tracker_story(grouping.pivotal_tracker_story_id) if grouping.pivotal_tracker_story_id.present?
    end
  end

  private

  def accept_tracker_story(story_id)
    story = @system_account.tracker.story(story_id)
    story.update("current_state" => "accepted")
    story.notes.create(:text => "Accepted since associated wat has been resolved.")
  end
end
