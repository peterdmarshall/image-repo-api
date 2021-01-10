Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :images, only: [:index, :show, :create, :delete] do
        post 'signed-url', to: 'images#signed_s3_upload_url'
      end
    end
  end
end
