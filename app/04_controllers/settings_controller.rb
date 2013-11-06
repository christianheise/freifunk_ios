class SettingsController < UITableViewController
  def init
    (super || self).tap do |it|
      it.tabBarItem = UITabBarItem.alloc.initWithTitle("Einstellungen", image:UIImage.imageNamed('settings.png'), tag:2)
    end
  end

  def reload
    tableView.reloadData
  end

  def loadView
    self.edgesForExtendedLayout = UIRectEdgeNone

    self.tableView = UITableView.alloc.tap do |tableView|
      tableView.initWithFrame(tableView.frame, style: UITableViewStyleGrouped)
      tableView.dataSource = tableView.delegate = self
    end
  end

  def viewWillAppear(animated)
    navigationItem.title = "With 💛 from St.Pauli"
  end

  def numberOfSectionsInTableView(tableView)
    3
  end

  def tableView(tableView, numberOfRowsInSection: section)
    case section
    when 0
      1
    when 2
      4
    when 1
      Region.all.size
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    case indexPath.section
    when 1
      tableView.dequeueReusableCellWithIdentifier(:text_cell) || UITableViewCell.alloc.tap do |cell|
        cell.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: :text_cell)
        cell.accessoryType  = UITableViewCellAccessoryNone
        cell.selectionStyle = UITableViewCellSelectionStyleNone
      end
    else
      tableView.dequeueReusableCellWithIdentifier(:link_cell) || UITableViewCell.alloc.tap do |cell|
        cell.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: :link_cell)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      end
    end
  end

  def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    case indexPath.section
    when 0
      cell.textLabel.text       = "Knoten aktualisieren"
      cell.detailTextLabel.text = "zuletzt aktualisiert #{delegate.file_loader.last_update}"
    when 1
      region = Region.all[indexPath.row]
      cell.textLabel.text = region.name
      if delegate.region == region
        cell.accessoryType  = UITableViewCellAccessoryCheckmark
        cell.selectionStyle = UITableViewCellSelectionStyleBlue
      else
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator
        cell.selectionStyle = UITableViewCellSelectionStyleGray
      end
    when 2
      case indexPath.row
      when 0
        cell.textLabel.text = "Freifunk #{delegate.region.name} auf Twitter"
      when 1
        cell.textLabel.text = "Freifunk #{delegate.region.name} Website"
      when 2
        cell.textLabel.text = "Coding: @phoet"
      when 3
        cell.textLabel.text = "Version: #{App.version}"
      end
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    case indexPath.section
    when 0
      current_cell = tableView.cellForRowAtIndexPath(indexPath)
      arrow = current_cell.accessoryView
      current_cell.accessoryView = spinner
      spinner.startAnimating

      delegate.file_loader.download do |state|
        current_cell.accessoryView = arrow
        spinner.stopAnimating
        if state
          reload_controllers
        else
          App.alert("Fehler beim laden...")
        end
      end
    when 1
      delegate.region = Region.all[indexPath.row]
      reload_controllers
    when 2
      case indexPath.row
      when 0
        open_url("http://twitter.com/#{delegate.region.twitter}")
      when 1
        open_url(delegate.region.homepage)
      when 2
        open_url("http://twitter.com/phoet")
      when 3
        open_url("https://www.github.com/phoet/freifunk_ios/")
      end
    end
  end

  protected

  def reload_controllers
    tabBarController.viewControllers.each do |navigation_controller|
      navigation_controller.viewControllers.each do |controller|
        controller.reload if controller.respond_to? :reload
      end
    end
  end

  def spinner
    @spinner ||= UIActivityIndicatorView.alloc.tap do |spinner|
      spinner.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
      spinner.frame = CGRectMake(0, 0, 24, 24)
    end
  end

  def open_url(url)
    url = NSURL.URLWithString(url)
    UIApplication.sharedApplication.openURL(url)
  end

  def delegate
    UIApplication.sharedApplication.delegate
  end
end
