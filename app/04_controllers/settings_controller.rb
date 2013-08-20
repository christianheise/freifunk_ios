class SettingsController < UITableViewController
  def init
    (super || self).tap do |it|
      it.tabBarItem = UITabBarItem.alloc.initWithTitle(nil, image:UIImage.imageNamed('settings.png'), tag:2)
    end
  end

  def reload
    tableView.reloadData
  end

  def loadView
    self.tableView = UITableView.alloc.tap do |tableView|
      tableView.dataSource = tableView.delegate = self
      tableView.initWithFrame(UIScreen.mainScreen.bounds, style: UITableViewStyleGrouped)
    end
  end

  def viewWillAppear(animated)
    navigationController.setNavigationBarHidden(true, animated: true)
  end

  def numberOfSectionsInTableView(tableView)
    4
  end

  def tableView(tableView, titleForHeaderInSection: section)
    return unless section == 0
    "With ♥ from St.Pauli"
  end

  def tableView(tableView, heightForHeaderInSection: section)
    section == 0 ? 50 : 0
  end

  def tableView(tableView, numberOfRowsInSection: section)
    if section == 0
      2
    elsif section == 1
      2
    elsif section == 2
      2
    else
      Region.all.size
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    if indexPath.section == 2 && indexPath.row == 1
      tableView.dequeueReusableCellWithIdentifier(:text_cell) || UITableViewCell.alloc.tap do |cell|
        cell.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: :text_cell)
        cell.accessoryType  = UITableViewCellAccessoryNone
        cell.selectionStyle = UITableViewCellSelectionStyleNone
      end
    elsif indexPath.section == 3
      tableView.dequeueReusableCellWithIdentifier(:region_cell) || UITableViewCell.alloc.tap do |cell|
        cell.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: :region_cell)
        cell.accessoryType  = UITableViewCellAccessoryNone
        cell.selectionStyle = UITableViewCellSelectionStyleNone
      end
    else
      tableView.dequeueReusableCellWithIdentifier(:link_cell) || UITableViewCell.alloc.tap do |cell|
        cell.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: :link_cell)
      end
    end
  end

  def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    if indexPath.section == 0
      if indexPath.row == 0
        cell.textLabel.text = "Coding: @phoet"
      else
        cell.textLabel.text = "Fork on GitHub"
      end
    elsif indexPath.section == 1
      if indexPath.row == 0
        cell.textLabel.text = "Freifunk #{Region.current.name} auf Twitter"
      else
        cell.textLabel.text = "Freifunk #{Region.current.name} Seite"
      end
    elsif indexPath.section == 2
      if indexPath.row == 0
        cell.textLabel.text = "Knoten aktualisieren"
      else
        cell.textLabel.text = "Version: #{App.version}"
      end
    else
      region = Region.all[indexPath.row]
      cell.textLabel.text = region.name
      if region == Region.current
        cell.accessoryType  = UITableViewCellAccessoryCheckmark
        cell.selectionStyle = UITableViewCellSelectionStyleBlue
      else
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator
        cell.selectionStyle = UITableViewCellSelectionStyleGray
      end
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    if indexPath.section == 0
      if indexPath.row == 0
        open_url("http://twitter.com/phoet")
      else
        open_url("https://www.github.com/phoet/freifunk_ios/")
      end
    elsif indexPath.section == 1
      if indexPath.row == 0
        open_url("http://twitter.com/#{Region.current.twitter}")
      else
        open_url(Region.current.homepage)
      end
    elsif indexPath.section == 2
      if indexPath.row == 0
        current_cell = tableView.cellForRowAtIndexPath(indexPath)
        current_cell.accessoryView = spinner
        spinner.startAnimating

        Node.download do |state|
          spinner.stopAnimating
          if state
            reload_controllers
            current_cell.textLabel.text = "Aktualisiert: #{Node.last_update}"
          else
            App.alert("Fehler beim laden...")
          end
        end
      end
    else
      Region.current = Region.all[indexPath.row]
      reload_controllers
    end
  end

  protected

  def reload_controllers
    Node.reset
    tabBarController.viewControllers.each do |controller|
      controller.reload if controller.respond_to? :reload
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
end
