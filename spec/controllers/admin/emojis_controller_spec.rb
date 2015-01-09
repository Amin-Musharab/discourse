require 'spec_helper'

describe Admin::EmojisController do

  let(:custom_emoji) do
    Emoji.new("/path/to/hello").tap do |e|
      e.name = "hello"
      e.url = "/url/to/hello.png"
    end
  end

  it "is a subclass of AdminController" do
    expect(Admin::EmojisController < Admin::AdminController).to eq(true)
  end

  context "when logged in" do
    let!(:user) { log_in(:admin) }

    context '.index' do
      it "returns a list of custom emojis" do
        Emoji.expects(:custom).returns([custom_emoji])
        xhr :get, :index
        expect(response).to be_success
        json = ::JSON.parse(response.body)
        expect(json[0]['name']).to eq(custom_emoji.name)
        expect(json[0]['url']).to eq(custom_emoji.url)
      end
    end

    context '.create' do

      before { Emoji.expects(:custom).returns([custom_emoji]) }

      context 'name already exist' do
        it "throws an error" do
          xhr :post, :create, { name: "hello", file: "" }
          expect(response).not_to be_success
        end
      end

      context 'error while saving emoji' do
        it "throws an error" do
          Emoji.expects(:create_for).returns(nil)
          xhr :post, :create, { name: "garbage", file: "" }
          expect(response).not_to be_success
        end
      end

      context 'it works' do
        let(:custom_emoji2) do
          Emoji.new("/path/to/hello2").tap do |e|
            e.name = "hello2"
            e.url = "/url/to/hello2.png"
          end
        end

        it "creates a custom emoji" do
          Emoji.expects(:create_for).returns(custom_emoji2)
          xhr :post, :create, { name: "hello2", file: ""}
          expect(response).to be_success
          json = ::JSON.parse(response.body)
          expect(json['name']).to eq(custom_emoji2.name)
          expect(json['url']).to eq(custom_emoji2.url)
        end

      end
    end

    context '.destroy' do
      it "deletes the custom emoji" do
        custom_emoji.expects(:remove)
        Emoji.expects(:custom).returns([custom_emoji])
        xhr :delete, :destroy, id: "hello"
        expect(response).to be_success
      end
    end
  end

end

