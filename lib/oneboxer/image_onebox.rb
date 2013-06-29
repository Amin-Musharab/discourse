require_dependency 'oneboxer/base_onebox'

module Oneboxer
  class ImageOnebox < BaseOnebox

    matcher /^https?:\/\/.*\.(jpg|png|gif|jpeg)$/

    def onebox
      Oneboxer::BaseOnebox.image_html(@url, nil, @url)
    end

  end
end
