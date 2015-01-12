require 'spec_helper'

describe GroupsController do
  let(:group) { Fabricate(:group) }

  describe 'show' do
    it "ensures the group can be seen" do
      Guardian.any_instance.expects(:can_see?).with(group).returns(false)
      xhr :get, :show, id: group.name
      expect(response).not_to be_success
    end

    it "responds with JSON" do
      Guardian.any_instance.expects(:can_see?).with(group).returns(true)
      xhr :get, :show, id: group.name
      expect(response).to be_success
      expect(::JSON.parse(response.body)['basic_group']['id']).to eq(group.id)
    end

    it "works even with an upper case group name" do
      Guardian.any_instance.expects(:can_see?).with(group).returns(true)
      xhr :get, :show, id: group.name.upcase
      expect(response).to be_success
      expect(::JSON.parse(response.body)['basic_group']['id']).to eq(group.id)
    end
  end

  describe "counts" do
    it "ensures the group can be seen" do
      Guardian.any_instance.expects(:can_see?).with(group).returns(false)
      xhr :get, :counts, group_id: group.name
      expect(response).not_to be_success
    end

    it "performs the query and responds with JSON" do
      Guardian.any_instance.expects(:can_see?).with(group).returns(true)
      Group.any_instance.expects(:posts_for).returns(Group.none)
      xhr :get, :counts, group_id: group.name
      expect(response).to be_success
    end
  end

  describe "posts" do
    it "ensures the group can be seen" do
      Guardian.any_instance.expects(:can_see?).with(group).returns(false)
      xhr :get, :posts, group_id: group.name
      expect(response).not_to be_success
    end

    it "calls `posts_for` and responds with JSON" do
      Guardian.any_instance.expects(:can_see?).with(group).returns(true)
      Group.any_instance.expects(:posts_for).returns(Group.none)
      xhr :get, :posts, group_id: group.name
      expect(response).to be_success
    end
  end

  describe "members" do
    it "ensures the group can be seen" do
      Guardian.any_instance.expects(:can_see?).with(group).returns(false)
      xhr :get, :members, group_id: group.name
      expect(response).not_to be_success
    end

    it "calls `posts_for` and responds with JSON" do
      Guardian.any_instance.expects(:can_see?).with(group).returns(true)
      xhr :get, :posts, group_id: group.name
      expect(response).to be_success
    end

    # Pending until we fix group truncation
    skip "ensures that membership can be paginated" do
      5.times { group.add(Fabricate(:user)) }
      usernames = group.users.map{ |m| m['username'] }.sort

      xhr :get, :members, group_id: group.name, limit: 3
      expect(response).to be_success
      members = JSON.parse(response.body)
      expect(members.map{ |m| m['username'] }).to eq(usernames[0..2])

      xhr :get, :members, group_id: group.name, limit: 3, offset: 3
      expect(response).to be_success
      members = JSON.parse(response.body)
      expect(members.map{ |m| m['username'] }).to eq(usernames[3..4])
    end
  end
end
