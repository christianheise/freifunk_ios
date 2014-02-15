class FileLoader
  attr_reader :region

  def initialize(region)
    @region = region
  end

  def download(&block)
    BW::HTTP.get(region.data_url) do |response|
      if state = response.ok?
        response.body.writeToFile(download_path, atomically: true)
      end
      block.call(state)
    end
  end

  def last_update
    File.mtime(file_path).strftime('%d.%m.%Y %H:%M')
  end

  def check_state(&block)
    BubbleWrap::HTTP.head(region.data_url) do |response|
      if state = !!response.headers
        remote  = NSDate.dateWithNaturalLanguageString(response.headers["Last-Modified"])
        local   = File.mtime(file_path)
        state   = remote > local
      end
      block.call(state)
    end
  end

  def download_path
    "#{App.documents_path}/#{region.key}.json"
  end

  def local_path
    "#{App.resources_path}/data/#{region.key}.json"
  end

  def file_path
    File.exists?(download_path) ? download_path : local_path
  end

  def load_nodes
    load_json do |json|
      json[:nodes].map do |it|
        node_id = it[:id]
        name    = it[:name]
        geo     = it[:geo]
        flags   = it[:flags]
        macs    = it[:macs]
        Node.new(node_id, name, geo, flags, macs)
      end
    end
  end

  def load_links
    load_json do |json|
      (json[:links] || []).map do |it|
        link_id = it[:id]
        quality = it[:quality]
        source  = it[:source]
        target  = it[:target]
        type    = it[:type]
        Link.new(link_id, quality, source, target, type)
      end
    end
  end

  def load_json
    content = File.open(file_path) { |file| file.read }
    yield BW::JSON.parse(content)
  rescue BubbleWrap::JSON::ParserError => e
    puts e
    []
  end
end
