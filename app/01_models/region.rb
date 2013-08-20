class Region < Struct.new(:key, :name, :location, :data_url, :twitter, :homepage)
  ALL = [
    Region.new(:hamburg, "Hamburg", [53.5, 10.0], "http://graph.hamburg.freifunk.net/nodes.json", "FreifunkHH", "http://hamburg.freifunk.net/"),
    Region.new(:luebeck, "Lübeck", [53.86972, 10.68639], "http://freifunk.metameute.de/map/nodes.json", "freifunkluebeck", "http://freifunk.metameute.de/"),
  ]

  def self.all
    ALL
  end

  def self.find(key)
    all.detect { |region| region.key == key }
  end

  def self.current
    if key = App::Persistence['region']
      find(key.to_sym)
    else
      ALL.first
    end
  end
  
  def self.current=(region)
    App::Persistence['region'] = region.key.to_s
    region
  end
end
