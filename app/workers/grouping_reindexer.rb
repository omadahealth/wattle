class GroupingReindexer
  include Sidekiq::Worker
  include Debounce

  DEBOUNCE_DELAY = 5.minutes

  def perform(grouping_id)
    Grouping.find(grouping_id).reindex
  end
end
