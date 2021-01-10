module Authenticable
    def current_user
        return @current_user if @current_user

        decoded = AuthorizationService.new(request.headers).authenticate_request!

        puts decoded

        @current_user = User.find_or_create_by(auth0_uid: decoded[:sub])

    rescue JWT::VerificationError, JWT::DecodeError
        render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end

    protected

    def check_login
        head :forbidden unless self.current_user
    end
end
