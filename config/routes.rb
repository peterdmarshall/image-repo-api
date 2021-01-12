Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :images, only: [:index, :show, :create, :destroy]
      get 'presigned-url', to: 'images#presigned_upload_url'
    end
  end
end
