# frozen_string_literal: true

Boilermaker::Engine.routes.draw do
  resource :settings, only: [:show, :edit, :update]
  root to: 'settings#show'
end 