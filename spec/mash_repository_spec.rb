describe MashRepository do
  it "validates the node" do
    repo.all.first.map(&:node_id).should.eql ["fa:1a:67:7e:af:12", "fa:1a:67:d8:e0:08"]
  end

  def repo
    MashRepository.new(loader.load_links, loader.load_nodes)
  end

  def loader
    @loader ||= FileLoader.new(Region::ALL.last)
  end
end


