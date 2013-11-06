class MapController < UIViewController
  include MapKit

  SPAN    = [3.1, 3.1]
  NEAR_IN = 14

  FILTER_ITEMS = ["Alle", "Online", "Offline", "Mesh"]

  def init
    (super || self).tap do |it|
      it.tabBarItem = UITabBarItem.alloc.initWithTitle("Karte", image: UIImage.imageNamed('location.png'), tag: 0)
    end
  end

  def loadView
    self.view = map
    add_controls
  end

  def viewDidLoad
    reload
  end

  def viewWillAppear(animated)
    navigationItem.title = "Map"
  end

  def viewDidDisappear(animated)
    disable_loading
  end

  def mapView(mapView, viewForOverlay: overlay)
    if overlay.is_a?(MKPolyline)
      view = MKPolylineView.alloc.initWithOverlay(overlay)
      view.lineWidth = 5
      view.strokeColor = UIColor.blueColor
      view
    end
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
    view.animatesDrop = mapView.zoom_level >= NEAR_IN - 1
    view.pinColor     = annotation.online? ? MKPinAnnotationColorGreen : MKPinAnnotationColorRed
    view
  end

  def mapView(mapView, rendererForOverlay: overlay)
    return unless overlay.is_a? MKPolyline

    MKPolylineRenderer.alloc.tap do |renderer|
      renderer.initWithPolyline(overlay)
      renderer.strokeColor = Color::LIGHT
      renderer.lineWidth   = 4
    end
  end

  def center(node)
    map.region = CoordinateRegion.new(node.coordinate, SPAN)
    map.set_zoom_level(NEAR_IN)
    map.selectAnnotation(node, animated: true)
  end

  def reload
    init_map
    filter_map
  end

  protected

  def timer
    @timer ||= EM.add_periodic_timer 5.0 do
      trigger_reload
    end
  end

  def trigger_reload
    @loading_button.enabled = false
    @loading_button.addSubview(loading_spinner)
    loading_spinner.startAnimating

    delegate.file_loader.download do |state|
      if state
        delegate.reload
        filter_map
      else
        App.alert("Fehler beim laden...")
      end
      loading_spinner.stopAnimating
      @loading_button.enabled = true
    end
  end

  def toggle_loading(sender)
    if @live_loading
      disable_loading
    else
      @live_loading = true
      @loading_button.tintColor = Color::LIGHT
      trigger_reload
      timer
    end
  end

  def disable_loading
    @live_loading = false
    @loading_button.tintColor = Color::GRAY
    EM.cancel_timer(timer) if timer
    @timer = nil
  end

  def show_details(sender)
    controller = DetailsController.new
    controller.node = map.selectedAnnotations[0]
    navigationController.pushViewController(controller, animated: true)
  end

  def filter_map(sender = nil)
    map.removeAnnotations(map.annotations.reject { |a| a.is_a? MKUserLocation })
    map.removeOverlays(map.overlays)
    case @control.selectedSegmentIndex
    when 0
      map.addAnnotations(delegate.node_repo.all)
    when 1
      map.addAnnotations(delegate.node_repo.online)
    when 2
      map.addAnnotations(delegate.node_repo.offline)
    when 3
      connections = delegate.link_repo.connections(delegate.node_repo.all)
      map.addAnnotations(connections.flatten.uniq)
      connections.each do |source, target|
        coords = Pointer.new(CLLocationCoordinate2D.type, 2)
        coords[0] = source.coordinate
        coords[1] = target.coordinate
        line = MKPolyline.polylineWithCoordinates(coords, count: 2)
        map.addOverlay(line)
      end
    end
  end

  def init_map
    map.region = CoordinateRegion.new(delegate.region.location, SPAN)
    map.set_zoom_level(delegate.region.zoom)
  end

  def map
    @map ||= MapView.new.tap do |map|
      map.delegate = self
      # map.frame    = CGRectMake(0, 0, 300, 600)
      map.frame = tabBarController.tabBar.frame
      # map.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      map.sizeToFit
    end
  end

  def add_controls
    margin  = 15
    padding = 5
    width   = view.frame.size.width - (2 * margin)
    height  = 40
    icon_size = 36

    @background = UIView.alloc.tap do |bg|
      bg.initWithFrame(CGRectMake(margin, margin, width, height))
      bg.layer.cornerRadius  = 5.0
      bg.layer.borderWidth   = 1.0
      bg.layer.borderColor   = Color::LIGHT.CGColor
      bg.backgroundColor     = Color::WHITE
      bg.autoresizingMask    = UIViewAutoresizingFlexibleWidth
    end
    view.addSubview @background

    @location_button = UIButton.buttonWithType(UIButtonTypeSystem).tap do |button|
      image = UIImage.imageNamed("map.png")
      button.frame = CGRectMake(5, 3, icon_size, icon_size)
      button.setImage(image, forState: UIControlStateNormal)
      button.setImage(image, forState: UIControlStateHighlighted)
      button.setImage(image, forState: UIControlStateSelected)
      button.tintColor = Color::GRAY
      button.addTarget(self, action: 'switch_to_user_location:', forControlEvents: UIControlEventTouchUpInside)
    end
    @background.addSubview @location_button

    @loading_button = UIButton.buttonWithType(UIButtonTypeSystem).tap do |button|
      image = UIImage.imageNamed("loopback.png")
      button.frame = CGRectMake(width - icon_size - 5, 3, icon_size, icon_size)
      button.setImage(image, forState: UIControlStateNormal)
      button.setImage(image, forState: UIControlStateHighlighted)
      button.setImage(image, forState: UIControlStateSelected)
      button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
      button.tintColor        = Color::GRAY
      button.addTarget(self, action: 'toggle_loading:', forControlEvents: UIControlEventTouchUpInside)
    end
    @background.addSubview @loading_button

    @control = UISegmentedControl.alloc.tap do |control|
      control.initWithItems(FILTER_ITEMS)
      control.frame                 = CGRectMake(icon_size + padding, padding, width - (2 * icon_size) - (3 * padding), control.frame.size.height)
      control.autoresizingMask      = UIViewAutoresizingFlexibleWidth
      control.selectedSegmentIndex  = 1
      control.tintColor             = Color::LIGHT
      control.addTarget(self, action: 'filter_map:', forControlEvents: UIControlEventValueChanged)
    end
    @background.addSubview @control
  end

  def switch_to_user_location(sender = nil)
    return unless BW::Location.enabled?
    @location_button.enabled = false
    @location_button.addSubview(location_spinner)
    location_spinner.startAnimating

    BW::Location.get_once do |result|
      coordinate  = LocationCoordinate.new(result)
      map.region = CoordinateRegion.new(coordinate, SPAN)
      map.shows_user_location = true
      map.set_zoom_level(NEAR_IN)
      location_spinner.stopAnimating
      @location_button.enabled = true
    end
  end

  def location_spinner
    @location_spinner ||= UIActivityIndicatorView.alloc.tap do |spinner|
      spinner.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
      spinner.frame = CGRectMake(0, 0, 36, 36)
    end
  end

  def loading_spinner
    @loading_spinner ||= UIActivityIndicatorView.alloc.tap do |spinner|
      spinner.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
      spinner.frame = CGRectMake(0, 0, 36, 36)
    end
  end

  def delegate
    UIApplication.sharedApplication.delegate
  end
end
