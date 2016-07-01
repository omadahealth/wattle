class DailyGroupingUpdater
  include Sidekiq::Worker

  def initialize
    @system_account = Watcher.retrieve_system_account
    PaperTrail.whodunnit = @system_account
  end

  def perform(app_name:)
    groupings = Grouping.app_name(app_name).where(state: :acknowledged).where("latest_wat_at <= ?", 15.days.ago)
    groupings.each do |grouping|
      grouping.resolve!
    end
  end
end
