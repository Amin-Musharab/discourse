class ActionDispatch::Session::DiscourseCookieStore < ActionDispatch::Session::CookieStore
  def initialize(app, options={})
    super(app,options)
  end

  private

  def set_cookie(request, session_id, cookie)
    if Hash === cookie
      if SiteSetting.force_https
        cookie[:secure] = true
      end
    end
    cookie_jar(request)[@key] = cookie
  end
end
