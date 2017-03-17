
GreekFire::Gauge.register "wats_count" do 
  Wat.where('created_at > ?', Time.zone.now.advance(minutes: -10)).count
end

GreekFire::Gauge.register "sidekiq_job_latency",
                          description: "How long are jobs enqueued",
                          labels: { :queue => Proc.new { Sidekiq::Queue.all.map(&:name) }} do | labels |
  Sidekiq::Queue.new(labels[:queue]).latency
end


GreekFire::Gauge.register "sidekiq_job_count",
                          description: "How many jobs are enqueued",
                          labels: { :queue => Proc.new { Sidekiq::Queue.all.map(&:name) }} do | labels |
  Sidekiq::Queue.new(labels[:queue]).size
end

