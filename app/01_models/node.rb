class Node
  include CoreLocation::DataTypes

  attr_reader :node_id, :name, :geo, :flags, :macs

  def initialize(node_id, name, geo, flags, macs)
    @node_id    = node_id
    @name       = name
    @geo        = geo
    @flags      = flags
    @macs       = macs.split(", ")
  end

  def title
    name
  end

  def subtitle
    node_id
  end

  def coordinate
    LocationCoordinate.new(geo.first, geo.last).api
  end

  def online?
    flags["online"]
  end

  def offline?
    !online?
  end

  def gateway?
    flags["gateway"]
  end

  def client?
    flags["client"]
  end

  def valid?
    !node_id.nil? && !name.nil? && !geo.nil?
  end

  def in_valid?
    !valid?
  end

  def self.download_path(key)
    "#{App.documents_path}/#{key}.json"
  end

  def self.local_path(key)
    "#{App.resources_path}/data/#{key}.json"
  end

  def self.file_path(key)
    File.exists?(download_path(key)) ? download_path(key) : local_path(key)
  end

  def self.all(region = Region.current)
    @nodes ||= begin
      content = File.open(file_path(region.key)) { |file| file.read }
      BW::JSON.parse(content)[:nodes].map do |it|
        node_id = it[:id]
        name    = it[:name]
        geo     = it[:geo]
        flags   = it[:flags]
        macs    = it[:macs]
        self.new(node_id, name, geo, flags, macs)
      end.reject(&:in_valid?)
    end
  end

  def self.sorted
    all.sort_by { |node| node.name.downcase }
  end

  def self.online
    all.select(&:online?)
  end

  def self.offline
    all.select(&:offline?)
  end

  def self.reset
    @nodes = nil
  end

  def self.download(region = Region.current, &block)
    BW::HTTP.get(region.data_url) do |response|
      if state = response.ok?
        response.body.writeToFile(download_path(region.key), atomically: true)
        reset
      end
      block.call(state)
    end
  end

  def self.last_update(region = Region.current)
    File.mtime(file_path(region.key)).strftime('%d.%m.%Y %H:%M')
  end

  def self.check_state(region = Region.current, &block)
    BubbleWrap::HTTP.head(region.data_url) do |response|
      if state = !!response.headers
        remote  = NSDate.dateWithNaturalLanguageString(response.headers["Last-Modified"])
        local   = File.mtime(file_path(region.key))
        state   = remote > local
      end
      block.call(state)
    end
  end

  def self.tokenize(string)
    string.split.map { |token| normalize(token) }.reject(&:empty?)
  end

  def self.normalize(string)
    string.gsub(/[^\w]/, '').downcase
  end

  def self.find(query)
    sorted.select do |node|
      tokenize(query).any? do |token|
        normalize(node.name) =~ /#{token}/
      end
    end
  end
end
