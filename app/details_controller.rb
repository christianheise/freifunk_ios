class DetailsController < UITableViewController
  attr_accessor :node

  def loadView
    self.tableView = UITableView.alloc.tap do |tableView|
      tableView.initWithFrame(UIScreen.mainScreen.bounds, style: UITableViewStyleGrouped)
      tableView.dataSource      = self
      tableView.delegate        = self
    end
  end

  def viewWillAppear(animated)
    navigationController.setNavigationBarHidden(false, animated: true)
    navigationItem.title = node.name
  end

  def numberOfSectionsInTableView(tableView)
    3
  end

  def tableView(tableView, titleForHeaderInSection: section)
    case section
    when 0
      "Info"
    when 1
      "Flags"
    when 2
      "Macs"
    end
  end

  def tableView(tableView, numberOfRowsInSection: section)
    case section
    when 0, 1
      3
    when 2
      node.macs.size
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    tableView.dequeueReusableCellWithIdentifier(:detail_cell) || UITableViewCell.alloc.tap do |cell|
      cell.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: :detail_cell)
      cell.accessoryType  = UITableViewCellAccessoryNone
      cell.selectionStyle = UITableViewCellSelectionStyleNone
    end
  end

  def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    case indexPath.section
    when 0
      case indexPath.row
      when 0
        cell.textLabel.text = node.name
      end
    end
  end

  def tableView(tableView, canEditRowAtIndexPath: indexPath)
    false
  end

  def tableView(tableView, canMoveRowAtIndexPath: indexPath)
    false
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    false
  end
end
