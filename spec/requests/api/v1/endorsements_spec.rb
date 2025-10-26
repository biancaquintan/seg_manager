# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Endorsements", type: :request do
  let(:user) { create(:user) }
  let(:policy) { create(:policy, sum_insured: 100_000.0, lmg: 100_000.0, start_date:  Date.current , end_date:  Date.current  + 1.year) }
  let(:today) {  Date.current  }

  describe "POST /api/v1/policies/:policy_id/endorsements" do
    context "increase sum insured" do
      let(:params) do
        {
          endorsement: {
            endorsement_type: "increase_sum_insured",
            new_sum_insured: 120_000.0,
            issue_date: today
          }
        }
      end

      it "creates an endorsement and updates LMG" do
        expect {
          post api_v1_policy_endorsements_path(policy),
               params: params.to_json,
               headers: auth_headers(user)
        }.to change(Endorsement, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(policy.reload.lmg).to eq(120_000.0)
      end
    end

    context "decrease sum insured" do
      let(:params) do
        {
          endorsement: {
            endorsement_type: "decrease_sum_insured",
            new_sum_insured: 80_000.0,
            issue_date: today
          }
        }
      end

      it "creates an endorsement and updates LMG" do
        expect {
          post api_v1_policy_endorsements_path(policy),
               params: params.to_json,
               headers: auth_headers(user)
        }.to change(Endorsement, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(policy.reload.lmg).to eq(80_000.0)
      end
    end

    context "change term only" do
      let(:params) do
        {
          endorsement: {
            endorsement_type: "change_term",
            new_start_date: policy.start_date + 10.days,
            new_end_date: policy.end_date + 10.days,
            issue_date: today
          }
        }
      end

      it "creates a term change endorsement without changing LMG" do
        original_start_date = policy.start_date
        original_end_date   = policy.end_date

        expect {
          post api_v1_policy_endorsements_path(policy),
              params: params.to_json,
              headers: auth_headers(user)
        }.to change(Endorsement, :count).by(1)

        expect(response).to have_http_status(:created)
        policy.reload
        expect(policy.lmg).to eq(100_000.0)
        expect(policy.start_date).to eq(original_start_date + 10.days)
        expect(policy.end_date).to eq(original_end_date + 10.days)
      end
    end

    context "increase sum insured and change term" do
      let(:params) do
        {
          endorsement: {
            endorsement_type: "increase_and_change_term",
            new_sum_insured: 130_000.0,
            new_start_date: policy.start_date + 5.days,
            new_end_date: policy.end_date + 5.days,
            issue_date: today
          }
        }
      end

      it "creates a combined endorsement and updates LMG and term" do
        expect {
          post api_v1_policy_endorsements_path(policy),
               params: params.to_json,
               headers: auth_headers(user)
        }.to change(Endorsement, :count).by(1)

        expect(response).to have_http_status(:created)
        policy.reload
        expect(policy.lmg).to eq(130_000.0)
        expect(policy.start_date).to eq(today + 5.days)
      end
    end

    context "decrease sum insured and change term" do
      let(:params) do
        {
          endorsement: {
            endorsement_type: "decrease_and_change_term",
            new_sum_insured: 90_000.0,
            new_start_date: policy.start_date + 7.days,
            new_end_date: policy.end_date + 7.days,
            issue_date: today
          }
        }
      end

      it "creates a combined endorsement and updates LMG and term" do
        expect {
          post api_v1_policy_endorsements_path(policy),
               params: params.to_json,
               headers: auth_headers(user)
        }.to change(Endorsement, :count).by(1)

        expect(response).to have_http_status(:created)
        policy.reload
        expect(policy.lmg).to eq(90_000.0)
        expect(policy.start_date).to eq(today + 7.days)
      end
    end

    context "cancellation" do
      let(:params) do
        {
          endorsement: {
            endorsement_type: "cancellation",
            issue_date: today
          }
        }
      end

      it "creates a cancellation endorsement and closes the policy" do
        expect {
          post api_v1_policy_endorsements_path(policy),
               params: params.to_json,
               headers: auth_headers(user)
        }.to change(Endorsement, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(policy.reload.status).to eq("closed")
      end
    end

    context "invalid params" do
      let(:params) do
        {
          endorsement: {
            endorsement_type: "",
            issue_date: today
          }
        }
      end

      it "does not create and returns validation errors" do
        expect {
          post api_v1_policy_endorsements_path(policy),
               params: params.to_json,
               headers: auth_headers(user)
        }.not_to change(Endorsement, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to be_present
      end
    end

    context "when policy is closed" do
      let(:closed_policy) do
        create(:policy, status: :closed, sum_insured: 100_000.0, lmg: 100_000.0)
      end

      let(:params) do
        {
          endorsement: {
            endorsement_type: "increase_sum_insured",
            new_sum_insured: 150_000.0,
            issue_date: today
          }
        }
      end

      it "does not allow creating an endorsement on a closed policy" do
        expect {
          post api_v1_policy_endorsements_path(closed_policy),
              params: params.to_json,
              headers: auth_headers(user)
        }.not_to change(Endorsement, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Cannot create endorsement for a closed policy")
      end
    end
  end
end
