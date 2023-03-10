# frozen_string_literal: true

class AdminConstraint
  def initialize(options = {})
    @require_master = options[:require_master]
  end

  def matches?(request)
    return false if @require_master && RailsMultisite::ConnectionManagement.current_db != "default"
    current_user = CurrentUser.lookup_from_env(request.env)
    current_user&.admin? && custom_admin_check(request)
  rescue Discourse::InvalidAccess, Discourse::ReadOnly
    false
  end

  # Extensibility point: plugins can overwrite this to add additional checks
  # if they require.
  def custom_admin_check(request)
    true
  end
end
