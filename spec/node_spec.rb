describe Node do
  it "reads nodes from file" do
    Node.all.size.should.satisfy { |result| result > 100 }
    Node.all.first.should.be.is_a? Node
  end

  it "has valid content" do
    Node.all.first.tap do |it|
      it.node_id.should.eql         "66:70:02:b5:d9:26"
      it.name.should.eql            "brachvogel05"
      it.geo.map(&:to_i).should.eql [53, 9]
      it.flags.should.eql           "client" => false, "gateway" => false, "online" => true
      it.macs.should.eql            "64:70:02:b5:d9:26, 66:70:02:b5:d9:26, 66:70:02:b5:d9:27, 66:70:02:b6:d9:26"
      it.coordinate.should.be.instance_of? CLLocationCoordinate2D
    end
  end
end
