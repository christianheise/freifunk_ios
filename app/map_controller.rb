class MapController < UIViewController
  include MapKit

  SPAN    = [3.1, 3.1]
  CENTER  = [53.5, 10.0]

  def viewDidLoad
    map = MapView.new
    map.frame = self.view.frame
    map.delegate = self
    map.region = CoordinateRegion.new(CENTER, SPAN)
    Node.all.each { |annotation| map.addAnnotation(annotation) }
    map.set_zoom_level(7)
    switch_to_user_location(map)

    view.addSubview(map)
  end

  private

  def switch_to_user_location(map)
    return unless BW::Location.enabled?
    BW::Location.get_once do |result|
      coordinate = LocationCoordinate.new(result)
      puts "coord #{coordinate}"
      map.region = CoordinateRegion.new(coordinate, SPAN)
      map.shows_user_location = true
      map.set_zoom_level(14)
    end
  end
end
