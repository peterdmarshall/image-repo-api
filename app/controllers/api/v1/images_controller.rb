require 'aws-sdk-s3'
require 'securerandom'

class Api::V1::ImagesController < ApplicationController
    before_action :set_image, only: [:show, :destroy, :update]
    before_action :check_login, only: [:index, :create, :signed_s3_upload_url]
    before_action :check_owner, only: [:show, :destroy, :update]
    before_action :set_s3_client, only: [:presigned_upload_url, :show, :destroy, :update]
    before_action :signed_url_params, only: [:presigned_upload_url]

    # GET /api/v1/images
    # Returns all Image records for the current user
    def index
        limit = params[:limit] || 10
        offset = params[:offset] || 0
        render json: { image_count: Image.where(user: current_user).count, images: Image.where(user: current_user).limit(limit.to_i).offset(offset.to_i) }
    end

    # GET /api/v1/images/:id
    # Returns URL to view image along with other file information (name, type, timestamp)
    # Generates pre-signed url to view image if it is private, or returns public URL if it is public
    def show
        resource = Aws::S3::Resource.new(client: @s3_client)
        bucket = resource.bucket(Rails.application.credentials.aws[:bucket])
        obj = bucket.object(@image.object_key)

        if @image.private
            # Generate a signed URL
            url = obj.presigned_url(:get)
            render json: { url: url, filename: @image.filename, filetype: @image.filetype }
        else
            # Generate a public URL
            url = obj.public_url()
            render json: { url: url, filename: @image.filename, filetype: @image.filetype }
        end
    end

    # POST /api/v1/images
    # Creates Image record with S3 object key and other file information (name, type, timestamp)
    def create
        image = Image.new(image_params.merge(user_id: current_user.id))
        if image.save
            render json: { image: image }
        else
            render json: { error: image.errors }
        end
    end

    # DELETE /api/v1/images/:id
    # Deletes Image record
    # Image is deleted from S3 by key
    def destroy
        # Delete from AWS
        resource = Aws::S3::Resource.new(client: @s3_client)
        bucket = resource.bucket(Rails.application.credentials.aws[:bucket])
        obj = bucket.object(@image.object_key)
        obj.delete()

        @image.destroy
        head 204
    end

    # PATCH /api/v1/images/:id
    # Updates stored image settings like Public/Private status
    # If image is set to public/private the corresponding s3 object is set to public/private accordingly
    def update

    end

    # POST /api/v1/images/signed-url
    # Returns a JSON object containing a signedUrl field for secure file upload from client
    # Presigned URL requires: Bucket (S3 Bucket name), Key (Name of object), Expires (Expiry time for URL)
    def presigned_upload_url
        filename = signed_url_params # First param is filename
        resource = Aws::S3::Resource.new(client: @s3_client)
        bucket = resource.bucket(Rails.application.credentials.aws[:bucket])

        object_key = "#{filename.split(".")[0]}-#{SecureRandom.uuid}.#{filename.split(".")[1]}"
        obj = bucket.object(object_key)
        url = obj.presigned_url(:put)
        render json: { presigned_url: url, object_key: object_key }

    rescue NameError
        render json: { error: "Failed to get presigned URL" }
    end

    private


    # Return 403 Forbidden if the requested resource does not belong to the requesting user
    def check_owner
        head :forbidden unless @image.user_id == current_user&.id
    end

    def set_image
        @image = Image.find(params[:id])

    rescue ActiveRecord::RecordNotFound
        head :not_found
    end

    def set_s3_client
        @s3_client = Aws::S3::Client.new(
            region:                 'us-east-1', # AWS region
            access_key_id:          Rails.application.credentials.aws[:access_key_id],
            secret_access_key:      Rails.application.credentials.aws[:secret_access_key]
        )
    end

    def image_params
        params.require(:image).permit(:object_key, :filename, :filetype, :private)
    end

    def signed_url_params
        params.require(:filename)
    end
end
