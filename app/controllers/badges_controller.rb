# frozen_string_literal: true

class BadgesController < ApplicationController
  skip_before_action :check_xhr, only: %i[index show]
  after_action :add_noindex_header

  def index
    raise Discourse::NotFound unless SiteSetting.enable_badges

    badges = Badge.all

    if search = params[:search]
      search = search.to_s
      badges = badges.where("name ILIKE ?", "%#{search}%")
    end

    if (params[:only_listable] == "true") || !request.xhr?
      # NOTE: this is sorted client side if needed
      badges =
        badges
          .includes(:badge_grouping)
          .includes(:badge_type, :image_upload)
          .where(enabled: true, listable: true)
    end

    badges = badges.to_a

    user_badges = nil
    if current_user
      user_badges = Set.new(current_user.user_badges.select("distinct badge_id").pluck(:badge_id))
    end
    serialized =
      MultiJson.dump(
        serialize_data(
          badges,
          BadgeIndexSerializer,
          root: "badges",
          user_badges: user_badges,
          include_long_description: true,
        ),
      )
    respond_to do |format|
      format.html do
        store_preloaded "badges", serialized
        render "default/empty"
      end
      format.json { render json: serialized }
    end
  end

  def show
    raise Discourse::NotFound unless SiteSetting.enable_badges

    params.require(:id)
    @badge = Badge.enabled.find(params[:id])
    @rss_title =
      I18n.t(
        "rss_description.badge",
        display_name: @badge.display_name,
        site_title: SiteSetting.title,
      )
    @rss_link = "#{Discourse.base_url}/badges/#{@badge.id}/#{@badge.slug}"

    if current_user
      user_badge = UserBadge.find_by(user_id: current_user.id, badge_id: @badge.id)
      user_badge.notification.update read: true if user_badge && user_badge.notification
      @badge.has_badge = true if user_badge
    end

    serialized =
      MultiJson.dump(
        serialize_data(@badge, BadgeSerializer, root: "badge", include_long_description: true),
      )
    respond_to do |format|
      format.rss { @rss_description = @badge.long_description }
      format.html { store_preloaded "badge", serialized }
      format.json { render json: serialized }
    end
  end
end
