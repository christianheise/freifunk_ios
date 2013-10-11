describe FileLoader do
  it "reads nodes from file" do
    nodes = loader.load_nodes
    nodes.size.should.satisfy { |result| result > 100 }
    nodes.first.should.be.is_a? Node
  end

  it "has valid nodes" do
    node = loader.load_nodes.first
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

  it "has valid links" do
    link = loader.load_links.first
    link.tap do |it|
      it.link_id.should.eql "66:70:02:5e:a9:1a-de:ad:be:ef:22:22"
      it.quality.should.eql "1.000, 1.000"
      it.source.should.eql  120
      it.target.should.eql  301
      it.type.should.eql    "vpn"
      it.macs.should.eql    ["66:70:02:5e:a9:1a", "de:ad:be:ef:22:22"]
    end
  end

  # it "downloads a new file" do
  #   @state = nil
  #   loader.download do |state|
  #     @state = state
  #     resume
  #   end
  #   wait_max(2.0) { @state.should == true }
  # end

  def loader
    FileLoader.new(Region::ALL.first)
  end
end
