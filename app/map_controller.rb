class MapController < UIViewController
  include MapKit

  SPAN    = [3.1, 3.1]
  CENTER  = [53.5, 10.0]

  FAR_OUT = 7
  NEAR_IN = 14

  FILTER_ITEMS = ["Alle", "💚 Online", "❤ Offline"]

  def loadView
    self.view = MapView.new
    view.delegate = self
    view.frame    = navigationController.view.bounds
    add_filters
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
      view.animatesDrop = mapView.zoom_level >= NEAR_IN
      view
    else
      MKPinAnnotationView.alloc.tap do |annotation_view|
        annotation_view.initWithAnnotation(annotation, reuseIdentifier: :node_annotation)
        annotation_view.canShowCallout  = true
        button = UIButton.buttonWithType(UIButtonTypeDetailDisclosure)
        button.addTarget(self, action: 'show_details:', forControlEvents: UIControlEventTouchUpInside)
        annotation_view.rightCalloutAccessoryView = button
      end
    end
  end

  private

    def show_details(sender)
      controller = DetailsController.new
      controller.node = view.selectedAnnotations[0]
      navigationController.pushViewController(controller, animated: true)
    end


    def filter_map(sender)
      view.removeAnnotations(view.annotations.reject { |a| a.is_a? MKUserLocation })
      case sender.selectedSegmentIndex
      when 0
        view.addAnnotations(Node.all)
      when 1
        view.addAnnotations(Node.all.select(&:online?))
      when 2
        view.addAnnotations(Node.all.select(&:offline?))
      end
    end

    def add_filters
      @control = UISegmentedControl.alloc.tap do |control|
        control.initWithItems(FILTER_ITEMS)
        control.frame                 = CGRectMake(10, 10, view.bounds.size.width - 20, control.frame.size.height)
        control.autoresizingMask      = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
        control.segmentedControlStyle = UISegmentedControlStyleBar
        control.selectedSegmentIndex  = 0
        control.addTarget(self, action: 'filter_map:', forControlEvents: UIControlEventValueChanged)
        view.addSubview(control)
      end
    end

    def switch_to_user_location
      return unless BW::Location.enabled?
      BW::Location.get_once do |result|
        coordinate = LocationCoordinate.new(result)
        view.region = CoordinateRegion.new(coordinate, SPAN)
        view.shows_user_location = true
        view.set_zoom_level(NEAR_IN, true)
      end
    end
end
