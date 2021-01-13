module Authenticable
    def current_user
        return @current_user if @current_user

        decoded = AuthorizationService.new(request.headers).authenticate_request!
        Rails.logger.debug "decoded: #{decoded}"


        # Get auth0_uid from token and find corresponding user
        auth0_uid = decoded[0]["sub"]
        Rails.logger.debug "auth0_uid: #{auth0_uid}"

        @current_user = User.find_or_create_by(auth0_uid: auth0_uid)

    rescue JWT::VerificationError, JWT::DecodeError
        render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end

    protected

    def check_login
        head :forbidden unless self.current_user
    end
end
