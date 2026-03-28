# frozen_string_literal: true

class SearchesController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @results = []

    if @query.present?
      service = SearchService.new(account: Current.account)
      @results = service.search(@query)
    end

    render Views::Searches::Index.new(
      query: @query,
      results: @results,
      has_embeddings: Current.account.has_embeddings?
    )
  end
end
