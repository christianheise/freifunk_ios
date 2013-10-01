class MashRepository
  attr_reader :links, :nodes, :lookup

  def initialize(links, nodes)
    @links  = links
    @nodes  = nodes
    @lookup = nodes.inject({}) do |hash, node|
      if node.valid?
        node.macs.each do |mac|
          hash[mac] = node
        end
      end
      hash
    end
  end

  def all
    links.map { |link|
      a = lookup[link.macs.first]
      b = lookup[link.macs.last]
      [a, b] if a && b
    }.reject(&:nil?)
  end
end
