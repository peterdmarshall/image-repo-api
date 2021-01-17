require 'aws-sdk-s3'

class Api::V1::BatchController < ApplicationController

    before_action :set_s3_client, only: [:delete_images]

    # POST /api/v1/batch/delete-images
    # Takes a JSON array of Image IDs to delete and returns an array
    # of successful deletions
    # Can improve performance by parallelizing using Active Job and Sidekiq. Currently
    # batching requests will only increase network performance by reducing # of requests
    # {
    #   images: [
    #     23, 
    #     24,
    #     27,
    #     54,
    #     55,
    #     ...etc
    #   ]
    # }
    def delete_images
        puts params
        image_ids = delete_params[:image_ids]
        deleted_ids = []

        image_ids.each do |id|
            # Set current image
            image = Image.find(id)

            # Skip if image does not belong to current user
            next if image.user_id != current_user&.id
            
            # Delete the image from s3 bucket by object_key
            resource = Aws::S3::Resource.new(client: @s3_client)
            bucket = resource.bucket(Rails.application.credentials.aws[:bucket])
            obj = bucket.object(image.object_key)
            obj.delete()

            # Remove the Image from ActiveRecord
            image.destroy

            # Add id to response
            deleted_ids.append(id)
        end

        # Return array of deleted images
        render json: { deleted: deleted_ids }, status: :ok
    end

    # GET /api/v1/batch/delete-images/:id/status
    # Check the status of the identified batch job
    # def delete_images_status
    #     # This method will allow the client to poll for the status of the Active Job
    #     # Will be implemented when batch_delete is parallelized using Active Job and Sidekiq
    # end

    private

    def set_s3_client
        @s3_client = Aws::S3::Client.new(
            region:                 'us-east-1', # AWS region
            access_key_id:          Rails.application.credentials.aws[:access_key_id],
            secret_access_key:      Rails.application.credentials.aws[:secret_access_key]
        )
    end

    def delete_params
        params.except(:format).permit(:image_ids => [])
    end

end
