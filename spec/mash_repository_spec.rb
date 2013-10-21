describe LinkRepository do
  it "validates the node" do
    repo.connections(loader.load_nodes).first.map(&:node_id).should.eql ["de:ad:be:ef:46:1d", "fe:54:00:2a:6b:e2"]
  end

  def repo
    LinkRepository.new(loader.load_links)
  end

  def loader
    @loader ||= FileLoader.new(Region::ALL.last)
  end
end


