class Node
  include CoreLocation::DataTypes

  attr_reader :node_id, :name, :geo, :flags, :macs

  def initialize(node_id, name, geo, flags, macs)
    @node_id    = node_id
    @name       = name
    @geo        = geo
    @flags      = flags
    @macs       = macs
  end

  def title
    name
  end

  def coordinate
    LocationCoordinate.new(geo.first, geo.last).api
  end

  def valid?
    !node_id.nil? && !name.nil? && !geo.nil?
  end

  def in_valid?
    !valid?
  end

  def self.all
    @nodes ||= begin
      file_path = "#{App.resources_path}/data/nodes.json"
      content = File.open(file_path) { |file| file.read }
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
end
