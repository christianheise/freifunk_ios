class MapController < UIViewController
  include MapKit

  attr_accessor :repo

  SPAN    = [3.1, 3.1]
  NEAR_IN = 14

  FILTER_ITEMS = ["Alle", "Online", "Offline"]

  def init
    (super || self).tap do |it|
      it.tabBarItem = UITabBarItem.alloc.initWithTitle("Karte", image: UIImage.imageNamed('location.png'), tag: 0)
    end
  end

  def reload
    init_repo
    filter_map(self)
    init_map
  end

  def loadView
    self.view = UIView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.view.addSubview map

    add_controls
  end

  def viewDidLoad
    init_repo
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
      @map.addAnnotations(repo.all)
    when 1
      @map.addAnnotations(repo.online)
    when 2
      @map.addAnnotations(repo.offline)
    end
  end

  def init_map
    @map.region = CoordinateRegion.new(region.location, SPAN)
    @map.set_zoom_level(region.zoom)
    @map.addAnnotations(repo.all)
  end

  def map
    @map = MapView.new.tap do |map|
      map.delegate = self
      map.frame    = UIScreen.mainScreen.bounds
      map.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    end
  end

  def add_controls
    @control = UISegmentedControl.alloc.tap do |control|
      control.initWithItems(FILTER_ITEMS)
      control.frame = CGRectMake(64, 20, view.frame.size.width - 84, control.frame.size.height)
      control.autoresizingMask = UIViewAutoresizingFlexibleWidth
      control.backgroundColor = UIColor.whiteColor
      control.selectedSegmentIndex  = 0
      control.addTarget(self, action: 'filter_map:', forControlEvents: UIControlEventValueChanged)
    end
    view.addSubview @control

    @button = UIButton.buttonWithType(UIButtonTypeSystem).tap do |button|
      image = UIImage.imageNamed("map.png")
      button.frame = CGRectMake(18, 18, 36, 36)
      button.setImage(image, forState: UIControlStateNormal)
      button.setImage(image, forState: UIControlStateHighlighted)
      button.setImage(image, forState: UIControlStateSelected)
      button.addTarget(self, action: 'switch_to_user_location:', forControlEvents: UIControlEventTouchUpInside)
    end
    view.addSubview @button
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
      spinner.frame = CGRectMake(0, 0, 36, 36)
    end
  end

  def region
    UIApplication.sharedApplication.delegate.region
  end

  def init_repo
    self.repo = NodeRepository.new FileLoader.new(region).load
  end
end
