class SettingsController < UITableViewController
  def init
    (super || self).tap do |it|
      it.tabBarItem = UITabBarItem.alloc.initWithTitle('Einstellungen', image:UIImage.imageNamed('settings.png'), tag:2)
    end
  end

  def loadView
    self.tableView = UITableView.alloc.tap do |tableView|
      tableView.initWithFrame(UIScreen.mainScreen.bounds, style: UITableViewStyleGrouped)
      tableView.dataSource = tableView.delegate = self
    end
  end

  def viewWillAppear(animated)
    navigationController.setNavigationBarHidden(true, animated: true)
  end

  def numberOfSectionsInTableView(tableView)
    3
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
      1
    elsif section == 1
      3
    else
      2
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    if indexPath.section == 2 && indexPath.row == 1
      tableView.dequeueReusableCellWithIdentifier(:text_cell) || UITableViewCell.alloc.tap do |cell|
        cell.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: :text_cell)
        cell.accessoryType            = UITableViewCellAccessoryNone
        cell.selectionStyle           = UITableViewCellSelectionStyleNone
      end
    else
      tableView.dequeueReusableCellWithIdentifier(:link_cell) || UITableViewCell.alloc.tap do |cell|
        cell.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: :link_cell)
        cell.accessoryType   = UITableViewCellAccessoryDisclosureIndicator
        cell.selectionStyle  = UITableViewCellSelectionStyleGray
      end
    end
  end

  def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    if indexPath.section == 0
      cell.textLabel.text = "Coding: @phoet"
    elsif indexPath.section == 1
      if indexPath.row == 0
        cell.textLabel.text = "Follow on Twitter"
      elsif indexPath.row == 1
        cell.textLabel.text = "Fork on GitHub"
      else
        cell.textLabel.text = "Freifunk Hamburg"
      end
    else
      if indexPath.row == 0
        cell.textLabel.text = "Knoten aktualisieren"
      else
        cell.textLabel.text = "Version: #{App.version}"
      end
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    if indexPath.section == 0
      open_url("http://twitter.com/phoet")
    elsif indexPath.section == 1
      if indexPath.row == 0
        open_url("http://twitter.com/FreifunkHH")
      elsif indexPath.row == 1
        open_url("https://www.github.com/phoet/freifunk_ios/")
      else
        open_url("http://hamburg.freifunk.net/")
      end
    else
      if indexPath.row == 0
        current_cell = tableView.cellForRowAtIndexPath(indexPath)
        current_cell.accessoryView = spinner
        spinner.startAnimating

        Node.download do |state|
          spinner.stopAnimating
          if state
            tabBarController.viewControllers.each do |controller|
              controller.reload if controller.respond_to? :reload
            end
            current_cell.textLabel.text = "Aktualisiert: #{Node.last_update}"
          else
            App.alert("Fehler beim laden...")
          end
        end
      end
    end
  end

  private

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
