module Api
  module V1
    class EndorsementsController < ApplicationController
      before_action :set_policy
      before_action :set_endorsement, only: [:show]

      # GET /api/v1/policies/:policy_id/endorsements
      def index
        endorsements = @policy.endorsements.order(created_at: :desc)
        render json: endorsements, each_serializer: EndorsementSerializer
      end

      # GET /api/v1/policies/:policy_id/endorsements/:id
      def show
        render json: @endorsement, serializer: EndorsementSerializer, include_policy: true
      end

      # POST /api/v1/policies/:policy_id/endorsements
      def create
        endorsement = EndorsementCreator.new(@policy, endorsement_params.to_h).call
        render json: endorsement, serializer: EndorsementSerializer, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def set_policy
        @policy = Policy.find(params[:policy_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Policy not found" }, status: :not_found
      end

      def set_endorsement
        @endorsement = @policy.endorsements.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Endorsement not found" }, status: :not_found
      end

      def endorsement_params
        params.require(:endorsement).permit(
          :issue_date,
          :endorsement_type,
          :new_sum_insured,
          :new_start_date,
          :new_end_date,
          :canceled_endorsement_id,
          :cancellation
        )
      end
    end
  end
end
