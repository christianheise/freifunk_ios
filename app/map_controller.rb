class MapController < UIViewController
  include MapKit

  def viewDidLoad
    map = MapView.new
    map.frame = self.view.frame
    map.delegate = self
    map.region = CoordinateRegion.new([53.5, 10.0], [3.1, 3.1])
    map.shows_user_location = true
    Node::DATA.each { |annotation| map.addAnnotation(annotation) }

    view.addSubview(map)
  end
end
