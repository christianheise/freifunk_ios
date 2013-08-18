class MapController < UIViewController
  include MapKit

  SPAN    = [3.1, 3.1]
  CENTER  = [53.5, 10.0]

  FAR_OUT = 7
  NEAR_IN = 14

  PADDING = 10

  FILTER_ITEMS = ["Alle", "💚 Online", "❤ Offline"]

  def init
    (super || self).tap do |it|
      it.tabBarItem = UITabBarItem.alloc.initWithTitle('Karte', image: UIImage.imageNamed('map.png'), tag: 0)
    end
  end

  def reload
    filter_map(self)
  end

  def loadView
    self.view = MapView.new
    view.delegate   = self
    view.frame      = tabBarController.view.bounds

    add_controls
  end

  def viewDidLoad
    view.region = CoordinateRegion.new(CENTER, SPAN)
    view.set_zoom_level(FAR_OUT)
    view.addAnnotations(Node.all)

    switch_to_user_location
  end

  def viewWillAppear(animated)
    navigationController.setNavigationBarHidden(true, animated: true)
  end

  def mapView(mapView, viewForAnnotation: annotation)
    return if annotation.is_a? MKUserLocation

    if view = mapView.dequeueReusableAnnotationViewWithIdentifier(:node_annotation)
      view.annotation   = annotation
      view
    else
      view = MKPinAnnotationView.alloc.tap do |it|
        it.initWithAnnotation(annotation, reuseIdentifier: :node_annotation)
        it.canShowCallout  = true
        button = UIButton.buttonWithType(UIButtonTypeInfoLight)
        button.addTarget(self, action: 'show_details:', forControlEvents: UIControlEventTouchUpInside)
        it.rightCalloutAccessoryView = button
      end
    end
    view.animatesDrop = mapView.zoom_level >= NEAR_IN
    view.pinColor     = annotation.online? ? MKPinAnnotationColorGreen : MKPinAnnotationColorRed
    view
  end

  def center(node)
    view.region = CoordinateRegion.new(node.coordinate, SPAN)
    view.set_zoom_level(NEAR_IN)
    view.selectAnnotation(node, animated: true)
  end

  protected

  def show_details(sender)
    controller = DetailsController.new
    controller.node = view.selectedAnnotations[0]
    navigationController.pushViewController(controller, animated: true)
  end

  def filter_map(sender)
    view.removeAnnotations(view.annotations.reject { |a| a.is_a? MKUserLocation })
    case @control.selectedSegmentIndex
    when 0
      view.addAnnotations(Node.all)
    when 1
      view.addAnnotations(Node.online)
    when 2
      view.addAnnotations(Node.offline)
    end
  end

  def add_controls
    button = UIButton.buttonWithType(UIButtonTypeContactAdd).tap do |it|
      image = UIImage.imageNamed("location.png")
      it.setImage(image, forState: UIControlStateNormal)
      it.setImage(image, forState: UIControlStateHighlighted)
      it.setImage(image, forState: UIControlStateSelected)
      it.frame            = CGRectMake(view.bounds.size.width - (PADDING + it.frame.size.width), PADDING, it.frame.size.width, it.frame.size.height)
      it.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin
      it.addTarget(self, action: 'switch_to_user_location:', forControlEvents: UIControlEventTouchUpInside)
    end
    view.addSubview(button)

    @control = UISegmentedControl.alloc.tap do |it|
      it.initWithItems(FILTER_ITEMS)
      it.frame                 = CGRectMake(PADDING, PADDING, it.frame.size.width - (button.frame.size.width + PADDING), button.frame.size.height)
      it.autoresizingMask      = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
      it.segmentedControlStyle = UISegmentedControlStyleBar
      it.selectedSegmentIndex  = 0
      it.addTarget(self, action: 'filter_map:', forControlEvents: UIControlEventValueChanged)
    end
    view.addSubview(@control)
  end

  def switch_to_user_location(sender = nil)
    return unless BW::Location.enabled?
    BW::Location.get_once do |result|
      coordinate  = LocationCoordinate.new(result)
      view.region = CoordinateRegion.new(coordinate, SPAN)
      view.shows_user_location = true
      view.set_zoom_level(NEAR_IN)
    end
  end
end
