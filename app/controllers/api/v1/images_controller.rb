class Api::V1::ImagesController < ApplicationController
    before_action :set_image, only: [:show, :destroy, :update]
    before_action :check_login, only: [:index, :create, :signed_s3_upload_url]
    before_action :check_owner, only: [:show, :destroy, :update]

    # GET /api/v1/images
    # Returns all Image records for the current user
    def index
        render json: { images: Image.where(user: current_user).all }
    end

    # GET /api/v1/images/:id
    # Returns URL to view image along with other file information (name, type, timestamp)
    # Generates pre-signed url to view image if it is private, or returns public URL if it is public
    def show
        render json: { image: @image }
    end

    # POST /api/v1/images
    # Creates Image record with S3 object key and other file information (name, type, timestamp)
    def create

    end

    # DELETE /api/v1/images/:id
    # Deletes Image record
    # Image is deleted from S3 by key
    def destroy

    end

    # PATCH /api/v1/images/:id
    # Updates stored image settings like Public/Private status
    # If image is set to public/private the corresponding s3 object is set to public/private accordingly
    def update

    end

    # POST /api/v1/images/signed-url
    # Returns a JSON object containing a signedUrl field for secure file upload from client
    def presigned_upload_url

    end

    private

    def check_owner
        head :forbidden unless @image.user_id == current_user&.id
    end

    def set_image
        @image = Image.find(params[:id])

    rescue ActiveRecord::RecordNotFound
        head :not_found
    end

    def image_params
        params.require(:image).permit(:url)
    end
end
