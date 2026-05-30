# frozen_string_literal: true

RSpec.describe Riemann::Tools::Opensearch::Health do
  subject(:health) do
    described_class.new(JSON.parse(<<~JSON))
      {
        "epoch": "1744081768",
        "timestamp": "03:09:28",
        "cluster": "opensearch",
        "status": "green",
        "node.total": "1",
        "node.data": "1",
        "discovered_cluster_manager": "true",
        "shards": "417",
        "pri": "417",
        "relo": "0",
        "init": "0",
        "unassign": "0",
        "pending_tasks": "0",
        "max_task_wait_time": "-",
        "active_shards_percent": "100.0%"
      }
    JSON
  end

  it { expect(health.epoch).to eq(1744081768) }
  it { expect(health.timestamp).to eq("03:09:28") }
  it { expect(health.cluster).to eq("opensearch") }
  it { expect(health.status).to eq("green") }
  it { expect(health.node.total).to eq(1) }
  it { expect(health.node.data).to eq(1) }
  it { expect(health.discovered_cluster_manager).to be(true) }
  it { expect(health.shards).to eq(417) }
  it { expect(health.pri).to eq(417) }
  it { expect(health.relo).to eq(0) }
  it { expect(health.init).to eq(0) }
  it { expect(health.unassign).to eq(0) }
  it { expect(health.pending_tasks).to eq(0) }
  it { expect(health.max_task_wait_time).to be_nil }
  it { expect(health.active_shards_percent).to eq(1.0) }
end
