
# encoding: UTF-8

class VirtualItems

    # VirtualItems::commit(item)
    def self.commit(item)
        key = "5224e064-4ddc-4bfc-a34b-0693942bc1ce:#{item["uuid"]}"
        XCache::set(key, JSON.generate(item))
    end

    # VirtualItems::getOrNull(uuid)
    def self.getOrNull(uuid)
        key = "5224e064-4ddc-4bfc-a34b-0693942bc1ce:#{uuid}"
        item = XCache::getOrNull(key)
        return nil if item.nil?
        JSON.parse(item)
    end
end
