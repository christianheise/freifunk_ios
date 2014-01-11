describe LinkRepository do
  it "validates the node" do
    repo.connections(loader.load_nodes).first.map(&:node_id).should.eql ["3a:3b:88:af:57:73", "66:66:b3:4c:94:e3"]
  end

  def repo
    LinkRepository.new(loader.load_links)
  end

  def loader
    @loader ||= FileLoader.new(Region::ALL.last)
  end
end


