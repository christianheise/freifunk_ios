class Region < Struct.new(:key, :name, :zoom, :location, :data_url, :twitter, :homepage)
  ALL = [
    Region.new(:hamburg,    "Hamburg",    7, [53.5, 10.0], "http://graph.hamburg.freifunk.net/nodes.json", "FreifunkHH",        "http://hamburg.freifunk.net/"),
    Region.new(:jena,       "Jena",       9, [50.9, 11.6], "http://map.freifunk-jena.de/ffmap/nodes.json", "freifunkjena",      "http://freifunk-jena.de/"),
    Region.new(:kiel,       "Kiel",       9, [54.3, 10.1], "http://freifunk.in-kiel.de/ffmap/nodes.json",  "freifunkkiel",      "http://freifunk.in-kiel.de/"),
    Region.new(:luebeck,    "Lübeck",     8, [53.8, 10.7], "http://freifunk.metameute.de/map/nodes.json",  "freifunkluebeck",   "http://freifunk.metameute.de/"),
    Region.new(:paderborn,  "Paderborn",  8, [51.7, 8.75], "http://map.paderborn.freifunk.net/nodes.json", "FreifunkPB",        "http://paderborn.freifunk.net/"),
  ]

  def self.all
    ALL
  end

  def self.find(key)
    all.detect { |region| region.key == key }
  end
end
