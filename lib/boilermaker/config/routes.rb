# frozen_string_literal: true

Boilermaker::Engine.routes.draw do
  resource :settings, only: [ :edit, :update ]
  root to: "settings#edit"
end
