module Gem
    def self.default_path
        [user_dir, default_dir, default_dir.gsub('gems','vendor_gems')]
    end
end
