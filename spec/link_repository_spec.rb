describe LinkRepository do
  it "validates the node" do
    repo.connections(loader.load_nodes).first.map(&:node_id).should.eql ["a2:f3:c1:cd:e4:6f", "dc624b6ae2a95d23b28dc21fb621b3af"]
  end

  def repo
    LinkRepository.new(loader.load_links)
  end

  def loader
    @loader ||= FileLoader.new(Region::ALL.last)
  end
end


