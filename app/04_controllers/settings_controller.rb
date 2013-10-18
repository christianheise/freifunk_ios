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
    self.tableView = UITableView.alloc.tap do |tableView|
      tableView.dataSource = tableView.delegate = self
      tableView.initWithFrame(UIScreen.mainScreen.bounds, style: UITableViewStyleGrouped)
    end
  end

  def viewWillAppear(animated)
    navigationController.setNavigationBarHidden(true, animated: true)
  end

  def numberOfSectionsInTableView(tableView)
    5
  end

  def tableView(tableView, viewForHeaderInSection: section)
    return unless section == 0
    UILabel.alloc.init.tap do |label|
      label.textAlignment = NSTextAlignmentCenter
      label.text = "With 💛 from St.Pauli"
      label.textColor = Color::LIGHT
      label.sizeToFit
    end
  end

  def tableView(tableView, heightForHeaderInSection: section)
    section == 0 ? 50 : 0
  end

  def tableView(tableView, numberOfRowsInSection: section)
    case section
    when 0, 2, 4
      1
    when 1
      2
    when 3
      Region.all.size
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    case indexPath.section
    when 0, 1, 2, 4
      tableView.dequeueReusableCellWithIdentifier(:link_cell) || UITableViewCell.alloc.tap do |cell|
        cell.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: :link_cell)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      end
    when 3
      tableView.dequeueReusableCellWithIdentifier(:text_cell) || UITableViewCell.alloc.tap do |cell|
        cell.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: :text_cell)
        cell.accessoryType  = UITableViewCellAccessoryNone
        cell.selectionStyle = UITableViewCellSelectionStyleNone
      end
    end
  end

  def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    case indexPath.section
    when 0
      cell.textLabel.text = "Coding: @phoet"
    when 1
      text = "Freifunk #{delegate.region.name} #{indexPath.row == 0 ? 'auf Twitter' : 'Seite'}" 
      cell.textLabel.text = text
    when 2
      cell.textLabel.text       = "Knoten aktualisieren"
      cell.detailTextLabel.text = "zuletzt aktualisiert #{delegate.file_loader.last_update}"
    when 3
      r = Region.all[indexPath.row]
      cell.textLabel.text = r.name
      if delegate.region == r
        cell.accessoryType  = UITableViewCellAccessoryCheckmark
        cell.selectionStyle = UITableViewCellSelectionStyleBlue
      else
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator
        cell.selectionStyle = UITableViewCellSelectionStyleGray
      end
    when 4
      cell.textLabel.text = "Version: #{App.version}"
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    case indexPath.section
    when 0
      open_url("http://twitter.com/phoet")
    when 1
      if indexPath.row == 0
        open_url("http://twitter.com/#{delegate.region.twitter}")
      else
        open_url(delegate.region.homepage)
      end
    when 2
      if indexPath.row == 0
        current_cell = tableView.cellForRowAtIndexPath(indexPath)
        current_cell.accessoryView = spinner
        spinner.startAnimating

        delegate.file_loader.download do |state|
          spinner.stopAnimating
          if state
            reload_controllers
          else
            App.alert("Fehler beim laden...")
          end
        end
      end
    when 3
      delegate.region = Region.all[indexPath.row]
      reload_controllers
    when 5
      open_url("https://www.github.com/phoet/freifunk_ios/")
    end
  end

  protected

  def reload_controllers
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

  def delegate
    UIApplication.sharedApplication.delegate
  end
end
