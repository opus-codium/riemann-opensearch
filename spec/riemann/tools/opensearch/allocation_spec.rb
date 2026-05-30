# frozen_string_literal: true

RSpec.describe Riemann::Tools::Opensearch::Allocation do
  subject(:allocation) do
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

  it { expect(allocation.shards).to eq(417) }
  it { expect(allocation.disk.indices).to eq(465570971987) }
  it { expect(allocation.disk.used).to eq(470372450304) }
  it { expect(allocation.disk.avail).to eq(3391202000896) }
  it { expect(allocation.disk.total).to eq(3861574451200) }
  it { expect(allocation.disk.percent).to eq(12) } # FIXME: OpenSearch should report something like "12 %"
  it { expect(allocation.host).to eq("127.0.0.1") }
  it { expect(allocation.ip).to eq("127.0.0.1") }
  it { expect(allocation.node).to eq("ns557263") }
end
