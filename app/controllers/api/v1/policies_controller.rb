module Api
  module V1
    class PoliciesController < ApplicationController
      before_action :set_policy, only: [:show]

      # GET /api/v1/policies
      def index
        policies = Policy.includes(:endorsements).order(created_at: :desc)
        render json: policies, each_serializer: PolicySerializer
      end

      # GET /api/v1/policies/:id
      def show
        render json: @policy, serializer: PolicySerializer
      end

      # POST /api/v1/policies
      def create
        policy = Policy.new(policy_params)
        if policy.save
          render json: policy, serializer: PolicySerializer, status: :created
        else
          render json: { errors: policy.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_policy
        @policy = Policy.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Policy not found" }, status: :not_found
      end

      def policy_params
        params.require(:policy).permit(:number, :issue_date, :start_date, :end_date, :sum_insured, :lmg, :status)
      end
    end
  end
end
