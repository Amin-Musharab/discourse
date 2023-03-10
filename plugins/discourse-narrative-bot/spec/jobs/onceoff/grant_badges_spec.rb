# frozen_string_literal: true

RSpec.describe Jobs::DiscourseNarrativeBot::GrantBadges do
  let(:user) { Fabricate(:user) }
  let(:other_user) { Fabricate(:user) }

  before do
    DiscourseNarrativeBot::Store.set(
      user.id,
      completed: [
        DiscourseNarrativeBot::NewUserNarrative.to_s,
        DiscourseNarrativeBot::AdvancedUserNarrative.to_s,
      ],
    )
  end

  it "should grant the right badges" do
    described_class.new.execute_onceoff({})

    expect(user.badges.count).to eq(2)

    expect(user.badges.map(&:name)).to contain_exactly(
      DiscourseNarrativeBot::NewUserNarrative.badge_name,
      DiscourseNarrativeBot::AdvancedUserNarrative.badge_name,
    )

    expect(other_user.badges.count).to eq(0)
  end
end
