class MapController < UIViewController
  include MapKit

  SPAN    = [3.1, 3.1]
  CENTER  = [53.5, 10.0]

  FAR_OUT = 7
  NEAR_IN = 14

  FILTER_ITEMS = ["Alle", "Online", "Offline"]

  def init
    (super || self).tap do |it|
      it.tabBarItem = UITabBarItem.alloc.initWithTitle(nil, image: UIImage.imageNamed('map.png'), tag: 0)
    end
  end

  def reload
    filter_map(self)
    init_map
  end

  def loadView
    @map = MapView.new
    @map.delegate = self
    @map.frame    = tabBarController.view.bounds
    @map.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight

    self.view = UIView.alloc.initWithFrame(tabBarController.view.bounds)
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.view.addSubview @map
    add_controls
  end

  def viewDidLoad
    init_map
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
    @map.region = CoordinateRegion.new(node.coordinate, SPAN)
    @map.set_zoom_level(NEAR_IN)
    @map.selectAnnotation(node, animated: true)
  end

  protected

  def show_details(sender)
    controller = DetailsController.new
    controller.node = @map.selectedAnnotations[0]
    navigationController.pushViewController(controller, animated: true)
  end

  def filter_map(sender)
    @map.removeAnnotations(@map.annotations.reject { |a| a.is_a? MKUserLocation })
    case @control.selectedSegmentIndex
    when 0
      @map.addAnnotations(Node.all)
    when 1
      @map.addAnnotations(Node.online)
    when 2
      @map.addAnnotations(Node.offline)
    end
  end

  def init_map
    @map.region = CoordinateRegion.new(Region.current.location, SPAN)
    @map.set_zoom_level(FAR_OUT)
    @map.addAnnotations(Node.all)
  end

  def add_controls
    @control = UISegmentedControl.alloc.tap do |it|
      it.initWithItems(FILTER_ITEMS)
      it.segmentedControlStyle = UISegmentedControlStyleBar
      it.selectedSegmentIndex  = 0
      it.addTarget(self, action: 'filter_map:', forControlEvents: UIControlEventValueChanged)
    end

    @button = UIButton.buttonWithType(UIButtonTypeCustom).tap do |it|
      image = UIImage.imageNamed("location.png")
      it.setImage(image, forState: UIControlStateNormal)
      it.setImage(image, forState: UIControlStateHighlighted)
      it.setImage(image, forState: UIControlStateSelected)
      it.addTarget(self, action: 'switch_to_user_location:', forControlEvents: UIControlEventTouchUpInside)
      it.nuiClass = 'Button:LocateButton'
    end

    Motion::Layout.new do |layout|
      layout.view self.view
      layout.subviews 'state' => @control, 'action' => @button
      layout.metrics    "margin" => 10, "height" => 32
      layout.horizontal "|-margin-[action(==height)]-[state]-margin-|"
      layout.vertical   "|-margin-[state(==height)]"
      layout.vertical   "|-margin-[action(==height)]"
    end
  end

  def switch_to_user_location(sender = nil)
    return unless BW::Location.enabled?
    @button.enabled = false
    @button.addSubview(spinner)
    spinner.startAnimating

    BW::Location.get_once do |result|
      coordinate  = LocationCoordinate.new(result)
      @map.region = CoordinateRegion.new(coordinate, SPAN)
      @map.shows_user_location = true
      @map.set_zoom_level(NEAR_IN)
      spinner.stopAnimating
      @button.enabled = true
    end
  end

  def spinner
    @spinner ||= UIActivityIndicatorView.alloc.tap do |spinner|
      spinner.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
      spinner.frame = CGRectMake(1, 1, 30, 30)
    end
  end
end
