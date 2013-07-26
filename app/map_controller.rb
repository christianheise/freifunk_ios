class MapController < UIViewController
  include MapKit

  SPAN    = [3.1, 3.1]
  CENTER  = [53.5, 10.0]

  FAR_OUT = 7
  NEAR_IN = 14

  def viewDidLoad
    map = MapView.new.tap do |map_view|
      map_view.frame    = self.view.frame
      map_view.delegate = self
      map_view.region   = CoordinateRegion.new(CENTER, SPAN)
      map_view.set_zoom_level(FAR_OUT)
    end

    add_annotations(map)
    switch_to_user_location(map)
    view.addSubview(map)
  end

  private

    def add_annotations(map)
      Node.all.each { |annotation| map.addAnnotation(annotation) }
    end

    def switch_to_user_location(map)
      return unless BW::Location.enabled?
      BW::Location.get_once do |result|
        coordinate = LocationCoordinate.new(result)
        map.region = CoordinateRegion.new(coordinate, SPAN)
        map.shows_user_location = true
        map.set_zoom_level(NEAR_IN)
      end
    end
end
