class ListController < UITableViewController
  attr_accessor :nodes

  def init
    (super || self).tap do |it|
      it.tabBarItem = UITabBarItem.alloc.initWithTitle('Liste', image:UIImage.imageNamed('list.png'), tag:1)
      it.nodes = Node.sorted
    end
  end

  def reload
    self.nodes = Node.sorted
    tableView.reloadData
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

  def tableView(tableView, numberOfRowsInSection:section)
    nodes.size
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    tableView.dequeueReusableCellWithIdentifier(:list_cell) || UITableViewCell.alloc.tap do |cell|
      cell.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: :list_cell)
      cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator
    end
  end

  def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    node = nodes[indexPath.row]
    cell.textLabel.text = node.name
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    controller = DetailsController.new
    controller.node = nodes[indexPath.row]
    navigationController.pushViewController(controller, animated: true)
  end
end
