Quipper::Application.routes.draw do
  resources :tasks do
    get 'done', on: :collection
    get 'pending', on: :collection
    get 'expired', on: :collection
  end

  root :to => "tasks#index"
end
