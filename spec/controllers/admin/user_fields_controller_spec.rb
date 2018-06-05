require 'rails_helper'

describe Admin::UserFieldsController do

  it "is a subclass of AdminController" do
    expect(Admin::UserFieldsController < Admin::AdminController).to eq(true)
  end

  context "when logged in" do
    let!(:user) { log_in(:admin) }

    context '.create' do
      it "creates a user field" do
        expect {
          post :create, params: {
            user_field: { name: 'hello', description: 'hello desc', field_type: 'text' }
          }, format: :json

          expect(response).to be_successful
        }.to change(UserField, :count).by(1)
      end

      it "creates a user field with options" do
        expect do
          post :create, params: {
            user_field: {
              name: 'hello',
              description: 'hello desc',
              field_type: 'dropdown',
              options: ['a', 'b', 'c']
            }
          }, format: :json

          expect(response).to be_successful
        end.to change(UserField, :count).by(1)

        expect(UserFieldOption.count).to eq(3)
      end
    end

    context '.index' do
      let!(:user_field) { Fabricate(:user_field) }

      it "returns a list of user fields" do
        get :index, format: :json
        expect(response).to be_successful
        json = ::JSON.parse(response.body)
        expect(json['user_fields']).to be_present
      end
    end

    context '.destroy' do
      let!(:user_field) { Fabricate(:user_field) }

      it "deletes the user field" do
        expect {
          delete :destroy, params: { id: user_field.id }, format: :json
          expect(response).to be_successful
        }.to change(UserField, :count).by(-1)
      end
    end

    context '.update' do
      let!(:user_field) { Fabricate(:user_field) }

      it "updates the user field" do
        put :update, params: {
          id: user_field.id,
          user_field: { name: 'fraggle', field_type: 'confirm', description: 'muppet' }
        }, format: :json

        expect(response).to be_successful
        user_field.reload
        expect(user_field.name).to eq('fraggle')
        expect(user_field.field_type).to eq('confirm')
      end

      it "updates the user field options" do
        put :update, params: {
          id: user_field.id,
          user_field: {
            name: 'fraggle',
            field_type: 'dropdown',
            description: 'muppet',
            options: ['hello', 'hello', 'world']
          }
        }, format: :json

        expect(response).to be_successful
        user_field.reload
        expect(user_field.name).to eq('fraggle')
        expect(user_field.field_type).to eq('dropdown')
        expect(user_field.user_field_options.size).to eq(2)
      end

      it "keeps options when updating the user field" do
        put :update, params: {
          id: user_field.id,
          user_field: {
            name: 'fraggle',
            field_type: 'dropdown',
            description: 'muppet',
            options: ['hello', 'hello', 'world'],
            position: 1
          }
        }, format: :json

        expect(response).to be_successful
        user_field.reload
        expect(user_field.user_field_options.size).to eq(2)

        put :update, params: {
          id: user_field.id,
          user_field: {
            name: 'fraggle',
            field_type: 'dropdown',
            description: 'muppet',
            position: 2
          }
        }, format: :json

        expect(response).to be_successful
        user_field.reload
        expect(user_field.user_field_options.size).to eq(2)
      end
    end
  end

end
