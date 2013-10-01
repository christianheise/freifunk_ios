class ListController < UITableViewController
  attr_accessor :repo, :nodes

  def init
    (super || self).tap do |it|
      it.tabBarItem = UITabBarItem.alloc.initWithTitle("Liste", image:UIImage.imageNamed('list.png'), tag:1)
      init_repo
    end
  end

  def reload
    init_repo
    tableView.reloadData
  end

  def loadView
    self.tableView = UITableView.alloc.tap do |tableView|
      tableView.initWithFrame(UIScreen.mainScreen.bounds, style: UITableViewStyleGrouped)
      tableView.dataSource = tableView.delegate = self
    end
    self.tableView.tableHeaderView = UISearchBar.alloc.tap do |search_bar|
      search_bar.initWithFrame(CGRectMake(0, 0, tableView.frame.size.width, 0))
      search_bar.delegate = self
      search_bar.sizeToFit
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
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      cell.textLabel.textColor = Color::MAIN
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
    self.nodes = repo.find(searchBar.text)
    tableView.reloadData
    searchBar.resignFirstResponder
  end

  def searchBarCancelButtonClicked(searchBar)
    self.nodes = repo.sorted
    tableView.reloadData
    tableView.scrollToRowAtIndexPath(NSIndexPath.indexPathForRow(0, inSection:0), atScrollPosition: UITableViewScrollPositionTop, animated: true)
    searchBar.resignFirstResponder
  end

  private

  def region
    UIApplication.sharedApplication.delegate.region
  end

  def search_and_reload(bar)
    text = bar.text
    if text && text.size > 1
      self.nodes = repo.find(text)
    else
      self.nodes = repo.sorted
    end
    tableView.reloadData
  end

  def init_repo
    self.repo = NodeRepository.new FileLoader.new(region).load
    self.nodes = repo.sorted
  end
end
