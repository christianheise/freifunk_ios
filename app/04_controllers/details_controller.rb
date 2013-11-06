class DetailsController < UITableViewController
  attr_accessor :node

  def loadView
    self.tableView = UITableView.alloc.tap do |tableView|
      tableView.initWithFrame(tableView.frame, style: UITableViewStyleGrouped)
      tableView.dataSource = tableView.delegate = self
    end
  end

  def viewWillAppear(animated)
    navigationController.setNavigationBarHidden(false, animated: true)
    navigationItem.title = node.name
  end

  def numberOfSectionsInTableView(tableView)
    4
  end

  def tableView(tableView, titleForHeaderInSection: section)
    {
      0 => "Info",
      1 => "Flags",
      2 => "Macs",
    }[section]
  end

  def tableView(tableView, numberOfRowsInSection: section)
    case section
    when 0, 1
      3
    when 2
      node.macs.size
    when 3
      1
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    (tableView.dequeueReusableCellWithIdentifier(:detail_cell) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: :detail_cell)).tap do |cell|
      if indexPath.section == 3
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator
        cell.selectionStyle = UITableViewCellSelectionStyleGray
      else
        cell.accessoryType  = UITableViewCellAccessoryNone
        cell.selectionStyle = UITableViewCellSelectionStyleNone
      end
    end
  end

  def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    case indexPath.section
    when 0
      case indexPath.row
      when 0
        cell.textLabel.text = node.name
      when 1
        cell.textLabel.text = node.node_id
      when 2
        cell.textLabel.text = node.geo.join(", ")
      end
    when 1
      case indexPath.row
      when 0
        cell.textLabel.text = "Online: #{node.online? ? 'Ja' : 'Nein'}"
      when 1
        cell.textLabel.text = "Client: #{node.client? ? 'Ja' : 'Nein'}"
      when 2
        cell.textLabel.text = "Gateway: #{node.gateway? ? 'Ja' : 'Nein'}"
      end
    when 2
      cell.textLabel.text = node.macs[indexPath.row]
    when 3
      cell.textLabel.text = "in Karte anzeigen"
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    if indexPath.section == 3
      if navigationController.tabBarController.selectedIndex == 1
        navigationController.tabBarController.viewControllers.first.popToRootViewControllerAnimated false
        navigationController.tabBarController.viewControllers.first.viewControllers.first.center node
        navigationController.tabBarController.selectedIndex = 0
      end

      navigationController.popViewControllerAnimated true
    end
  end
end