
GreekFire::Gauge.register "wats_count",  "The number of wats created in the last 10 minutes.", {} do
  Wat.where('created_at > ?', Time.zone.now.advance(minutes: -10)).count
end

GreekFire::Gauge.register "sidekiq_queue_latency", "How long has the old job waited for enqueuing", {} do
  Sidekiq::Queue.all.map do |x|
    x.latency
  end.max
end

GreekFire::Gauge.register "sidekiq_queue_count", "How many jobs are enqueued", {} do
  Sidekiq::Queue.all.map do |x|
    x.size
  end.sum
end

