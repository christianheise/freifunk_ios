describe FileLoader do
  it "reads nodes from file" do
    nodes = loader.load
    nodes.size.should.satisfy { |result| result > 100 }
    nodes.first.should.be.is_a? Node
  end

  it "has valid content" do
    node = loader.load.first
    node.tap do |it|
      it.node_id.should.eql         "66:70:02:b5:d9:26"
      it.name.should.eql            "brachvogel05"
      it.title.should.eql           "brachvogel05"
      it.subtitle.should.eql        "66:70:02:b5:d9:26"
      it.geo.map(&:to_i).should.eql [53, 9]
      it.flags.should.eql           "client" => false, "gateway" => false, "online" => true
      it.macs.should.include("64:70:02:b5:d9:26")
      it.online?.should.eql         true
      it.client?.should.eql         false
      it.gateway?.should.eql        false
      it.coordinate.should.be.instance_of? CLLocationCoordinate2D
    end
  end

  it "downloads a new file" do
    @state = nil
    loader.download do |state|
      @state = state
    end
    wait_max(1) { @state.should.not.eql nil }
  end

  def loader
    FileLoader.new(Region::ALL.first)
  end
end
