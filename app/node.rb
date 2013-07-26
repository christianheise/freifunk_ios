class Node
  include CoreLocation::DataTypes

  def initialize(title, lat, long)
    @title    = title
    @location = LocationCoordinate.new(lat, long)
  end

  def title
    @name
  end

  def coordinate
    @location.api
  end

  DATA = [
    Node.new('Lagavulin', 55.6355209350586, -6.12622451782227),
    Node.new('Laphroaig', 55.6298294067383, -6.15358829498291),
    Node.new('Ardbeg',    55.6420860290527, -6.11207962036133),
  ]
end
