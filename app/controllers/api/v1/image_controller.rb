class Api::V1::ImagesController < ApplicationController
    before_action :check_login, only: [:index, :create, :signed_s3_upload_url]
    before_action :check_owner, only: [:show, :delete, :update]

    # GET /api/v1/images
    # Returns all Image records for the current user
    def index
        render json: Image.where(user: current_user).all
    end

    # GET /api/v1/images/:id
    # Returns the Image record containing the S3 url 
    def show

    end

    # POST /api/v1/images
    # Creates Image record with S3 URL, file type, and timestamp
    def create

    end

    # DELETE /api/v1/images/:id
    # Deletes image record from ActiveStorage and returns success / failure
    # Image is deleted from S3 lazily as it is not important from UX perspective
    def delete

    end

    # PATCH /api/v1/images/:id
    # Updates stored image metadata like Public/Private status
    def update

    end

    # POST /api/v1/images/signed-url
    # Returns a JSON object containing a signedUrl field for secure file upload from client
    def signed_s3_upload_url

    end

    private

    def check_owner
        head :forbidden unless @image.user_id == current_user&.id
    end

    def set_image
        @image = Image.find(params[:id])
    end

    def image_params
        params.require(:image).permit(:url)
    end
end
