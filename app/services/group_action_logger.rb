# frozen_string_literal: true

class GroupActionLogger
  def initialize(acting_user, group)
    @acting_user = acting_user
    @group = group
  end

  def log_make_user_group_owner(target_user)
    GroupHistory.create!(
      default_params.merge(
        action: GroupHistory.actions[:make_user_group_owner],
        target_user: target_user,
      ),
    )
  end

  def log_remove_user_as_group_owner(target_user)
    GroupHistory.create!(
      default_params.merge(
        action: GroupHistory.actions[:remove_user_as_group_owner],
        target_user: target_user,
      ),
    )
  end

  def log_add_user_to_group(target_user, subject = nil)
    GroupHistory.create!(
      default_params.merge(
        action: GroupHistory.actions[:add_user_to_group],
        target_user: target_user,
        subject: subject,
      ),
    )
  end

  def log_remove_user_from_group(target_user, subject = nil)
    GroupHistory.create!(
      default_params.merge(
        action: GroupHistory.actions[:remove_user_from_group],
        target_user: target_user,
        subject: subject,
      ),
    )
  end

  def log_change_group_settings
    @group
      .previous_changes
      .except(*excluded_attributes)
      .each do |attribute_name, value|
        next if value[0].blank? && value[1].blank?

        GroupHistory.create!(
          default_params.merge(
            action: GroupHistory.actions[:change_group_setting],
            subject: attribute_name,
            prev_value: value[0],
            new_value: value[1],
          ),
        )
      end
  end

  private

  def excluded_attributes
    %i[bio_cooked updated_at created_at user_count]
  end

  def default_params
    { group: @group, acting_user: @acting_user }
  end
end
