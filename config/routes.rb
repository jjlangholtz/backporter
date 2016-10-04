Rails.application.routes.draw do
  post '/webhooks', to: 'webhooks#create'
end
