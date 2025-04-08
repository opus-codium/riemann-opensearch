# frozen_string_literal: true

RSpec.describe Riemann::Tools::OpenSearch::Allocation do
  subject do
    described_class.new(JSON.parse(<<~JSON))
      {
        "shards": "417",
        "disk.indices": "465570971987",
        "disk.used": "470372450304",
        "disk.avail": "3391202000896",
        "disk.total": "3861574451200",
        "disk.percent": "12",
        "host": "127.0.0.1",
        "ip": "127.0.0.1",
        "node": "ns557263"
      }
    JSON
  end

  it "parse allocation correctly" do
    expect(subject.shards).to eq(417)
    expect(subject.disk.indices).to eq(465570971987)
    expect(subject.disk.used).to eq(470372450304)
    expect(subject.disk.avail).to eq(3391202000896)
    expect(subject.disk.total).to eq(3861574451200)
    expect(subject.disk.percent).to eq(12) # FIXME: OpenSearch should report something like "12 %"
    expect(subject.host).to eq("127.0.0.1")
    expect(subject.ip).to eq("127.0.0.1")
    expect(subject.node).to eq("ns557263")
  end
end

RSpec.describe Riemann::Tools::OpenSearch::Health do
  subject do
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

  it "parse health correctly" do
    expect(subject.epoch).to eq(1744081768)
    expect(subject.timestamp).to eq("03:09:28")
    expect(subject.cluster).to eq("opensearch")
    expect(subject.status).to eq("green")
    expect(subject.node.total).to eq(1)
    expect(subject.node.data).to eq(1)
    expect(subject.discovered_cluster_manager).to eq(true)
    expect(subject.shards).to eq(417)
    expect(subject.pri).to eq(417)
    expect(subject.relo).to eq(0)
    expect(subject.init).to eq(0)
    expect(subject.unassign).to eq(0)
    expect(subject.pending_tasks).to eq(0)
    expect(subject.max_task_wait_time).to be_nil
    expect(subject.active_shards_percent).to eq(1.0)
  end
end
