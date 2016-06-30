class AddKairosSystemAccount < ActiveRecord::Migration
  class Watcher < ActiveRecord::Base; end

  def up
    Watcher.first_or_create!(name: "Kairos' Robot", email: "kairos-robot@omadahealth.com")
  end

  def down
    Watcher.find_by_email("kairos-robot@omadahealth.com").destroy
  end
end
