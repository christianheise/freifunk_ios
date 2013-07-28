class MapController < UIViewController
  include MapKit

  SPAN    = [3.1, 3.1]
  CENTER  = [53.5, 10.0]

  FAR_OUT = 7
  NEAR_IN = 14

  FILTER_ITEMS = ["alle", "💚 online", "❤ offline"]

  def viewDidLoad
    @map = MapView.new.tap do |map_view|
      map_view.frame    = self.view.bounds
      map_view.delegate = self
      map_view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth
      map_view.region   = CoordinateRegion.new(CENTER, SPAN)
      map_view.set_zoom_level(FAR_OUT)
      map_view.addAnnotations(Node.all)
    end

    switch_to_user_location
    add_filters

    view.addSubview(@map)
  end

  private

    def filter_map(sender)
      @map.removeAnnotations(@map.annotations)
      case sender.selectedSegmentIndex
      when 0
        @map.addAnnotations(Node.all)
      when 1
        @map.addAnnotations(Node.all.select(&:online?))
      when 2
        @map.addAnnotations(Node.all.select(&:offline?))
      end
    end

    def add_filters
      UISegmentedControl.alloc.tap do |control|
        control.initWithItems(FILTER_ITEMS)
        control.frame                 = CGRectMake(10, 10, @map.bounds.size.width - 20, control.frame.size.height)
        control.autoresizingMask      = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
        control.segmentedControlStyle = UISegmentedControlStyleBar
        control.selectedSegmentIndex  = 0
        control.tintColor             = UIColor.blackColor
        control.addTarget(self, action: 'filter_map:', forControlEvents: UIControlEventValueChanged)
        @map.addSubview(control)
      end
    end

    def switch_to_user_location
      return unless BW::Location.enabled?
      BW::Location.get_once do |result|
        coordinate = LocationCoordinate.new(result)
        @map.region = CoordinateRegion.new(coordinate, SPAN)
        @map.shows_user_location = true
        @map.set_zoom_level(NEAR_IN)
      end
    end
end
