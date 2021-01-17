Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'presigned-url', to: 'images#presigned_upload_url'
      post 'batch/delete-images', to: 'batch#delete_images'
      get 'batch/delete-images/:id/status', to: 'batch#delete_images_status'
      resources :images, only: [:index, :show, :create, :destroy, :update]
    end
  end
end
