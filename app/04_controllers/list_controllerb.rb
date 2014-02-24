class ListController < UITableViewController
  attr_accessor :nodes

  def init
    (super || self).tap do |it|
      it.tabBarItem = UITabBarItem.alloc.initWithTitle("Liste", image:UIImage.imageNamed('list.png'), tag:1)
    end
  end

  def loadView
    init_nodes

    self.tableView = UITableView.alloc.tap do |tableView|
      tableView.initWithFrame(tableView.frame, style: UITableViewStyleGrouped)
      tableView.dataSource = tableView.delegate = self
    end
    self.tableView.tableHeaderView = UISearchBar.alloc.tap do |search_bar|
      search_bar.initWithFrame(CGRectZero)
      search_bar.delegate = self
      search_bar.sizeToFit
    end
  end

  def viewWillAppear(animated)
    navigationItem.title = "Freifunk Knoten #{delegate.region.name}"
  end

  def tableView(tableView, numberOfRowsInSection:section)
    nodes.size
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    tableView.dequeueReusableCellWithIdentifier(:list_cell) || UITableViewCell.alloc.tap do |cell|
      cell.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: :list_cell)
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
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

  def searchBarTextDidBeginEditing(searchBar)
    searchBar.setShowsCancelButton(true, animated: true)
  end

  def searchBarTextDidEndEditing(searchBar)
    searchBar.setShowsCancelButton(false, animated: true)
  end

  def searchBar(searchBar, textDidChange: searchText)
    search_and_reload(searchBar)
  end

  def searchBar(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
    search_and_reload(searchBar)
  end

  def searchBarSearchButtonClicked(searchBar)
    self.nodes = delegate.node_repo.find(searchBar.text)
    tableView.reloadData
    searchBar.resignFirstResponder
  end

  def searchBarCancelButtonClicked(searchBar)
    self.nodes = delegate.node_repo.sorted
    tableView.reloadData
    tableView.scrollToRowAtIndexPath(NSIndexPath.indexPathForRow(0, inSection:0), atScrollPosition: UITableViewScrollPositionTop, animated: true)
    searchBar.resignFirstResponder
  end

  def reload
    init_nodes
    tableView.reloadData
  end

  private

  def delegate
    UIApplication.sharedApplication.delegate
  end

  def init_nodes
    self.nodes = delegate.node_repo.sorted
  end

  def search_and_reload(bar)
    text = bar.text
    if text && text.size > 1
      self.nodes = delegate.node_repo.find(text)
    else
      self.nodes = delegate.node_repo.sorted
    end
    tableView.reloadData
  end
end
