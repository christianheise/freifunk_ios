describe Node do
  it "validates the node" do
    data = ["node_id", "name", "geo", "flags", "macs"]
    Node.new(*data).valid?.should.eql true
  end
end
