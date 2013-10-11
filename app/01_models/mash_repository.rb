class MashRepository
  attr_reader :links

  def initialize(links)
    @links = links
  end

  def connections(nodes)
    lookup = nodes.each_with_object({}) do |node, hash|
      node.macs.each do |mac|
        hash[mac] = node
      end
    end

    links.map { |link|
      a = lookup[link.macs.first]
      b = lookup[link.macs.last]
      [a, b] if a && b
    }.reject(&:nil?)
  end
end
