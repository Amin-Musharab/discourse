# frozen_string_literal: true

class ActionDispatch::Session::DiscourseCookieStore < ActionDispatch::Session::CookieStore
  def initialize(app, options = {})
    super(app, options)
  end

  private

  def set_cookie(request, session_id, cookie)
    if Hash === cookie
      cookie[:secure] = true if SiteSetting.force_https
      unless SiteSetting.same_site_cookies == "Disabled"
        cookie[:same_site] = SiteSetting.same_site_cookies
      end
    end
    cookie_jar(request)[@key] = cookie
  end
end
