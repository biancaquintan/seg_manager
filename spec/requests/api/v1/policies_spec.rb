# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Policies", type: :request do
  let!(:user) { create(:user) }
  let!(:policies) { create_list(:policy, 3) }
  let(:policy) { policies.first }

  describe "GET /api/v1/policies" do
    it "returns paginated list of policies" do
      get api_v1_policies_path(per_page: 3), headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      expect(json_response[:data].size).to eq(3)
    end
  end

  describe "GET /api/v1/policies/:id" do
    context "when policy exists" do
      it "returns the policy" do
        get api_v1_policy_path(policy), headers: auth_headers(user)
        expect(response).to have_http_status(:ok)
        expect(json_response[:id]).to eq(policy.id)
      end
    end

    context "when policy does not exist" do
      it "returns 404 not found" do
        get api_v1_policy_path(id: 0), headers: auth_headers(user)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/policies" do
    let(:valid_params) { { policy: attributes_for(:policy) }.to_json }
    let(:invalid_params) { { policy: { number: nil } }.to_json }

    context "with valid params" do
      it "creates a new policy" do
        expect {
          post api_v1_policies_path, params: valid_params, headers: auth_headers(user)
        }.to change(Policy, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid params" do
      it "does not create and returns errors" do
        expect {
          post api_v1_policies_path, params: invalid_params, headers: auth_headers(user)
        }.not_to change(Policy, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_empty
      end
    end
  end
end
