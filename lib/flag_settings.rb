# frozen_string_literal: true

class FlagSettings
  attr_reader(
    :without_custom_types,
    :notify_types,
    :topic_flag_types,
    :auto_action_types,
    :custom_types,
  )

  def initialize
    @all_flag_types = Enum.new
    @topic_flag_types = Enum.new
    @notify_types = Enum.new
    @auto_action_types = Enum.new
    @custom_types = Enum.new
    @without_custom_types = Enum.new
  end

  def add(id, name, topic_type: nil, notify_type: nil, auto_action_type: nil, custom_type: nil)
    @all_flag_types[name] = id
    @topic_flag_types[name] = id if !!topic_type
    @notify_types[name] = id if !!notify_type
    @auto_action_types[name] = id if !!auto_action_type

    if !!custom_type
      @custom_types[name] = id
    else
      @without_custom_types[name] = id
    end
  end

  def is_flag?(key)
    @all_flag_types.valid?(key)
  end

  def flag_types
    @all_flag_types
  end
end
