# frozen_string_literal: true

class SiteSettingsTask
  def self.export_to_hash(include_defaults: false, include_hidden: false)
    site_settings = SiteSetting.all_settings(include_hidden: include_hidden)
    h = {}
    site_settings.each do |site_setting|
      next if site_setting[:default] == site_setting[:value] if !include_defaults
      h.store(site_setting[:setting].to_s, site_setting[:value])
    end
    h
  end

  def self.import(yml)
    h = SiteSettingsTask.export_to_hash(include_defaults: true, include_hidden: true)
    counts = { updated: 0, not_found: 0, errors: 0 }
    log = []

    site_settings = YAML.safe_load(yml)
    site_settings.each do |site_setting|
      key = site_setting[0]
      val = site_setting[1]
      if h.has_key?(key)
        if val != h[key] #only update if different
          begin
            result = SiteSetting.set_and_log(key, val)
            log << "Changed #{key} FROM: #{result.previous_value} TO: #{result.new_value}"
            counts[:updated] += 1
          rescue => e
            log << "ERROR: #{e.message}"
            counts[:errors] += 1
          end
        end
      else
        log << "NOT FOUND: existing site setting not found for #{key}"
        counts[:not_found] += 1
      end
    end
    [log, counts]
  end
end
