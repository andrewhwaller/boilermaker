# frozen_string_literal: true

class Views::Searches::Index < Views::Base
  def initialize(query: "", results: [])
    @query = query
    @results = results
  end

  def view_template
    page_with_title("Search") do
      div(class: "max-w-3xl mx-auto space-y-6") do
        search_form
        if @query.present?
          if @results.any?
            results_list
          else
            no_results
          end
        else
          empty_state
        end
      end
    end
  end

  private

  def search_form
    form_with(url: searches_path, method: :get, class: "flex gap-2") do |f|
      div(class: "flex-1") do
        input(
          type: "text",
          name: "q",
          value: @query,
          placeholder: "Search your library...",
          class: "ui-input w-full",
          autofocus: true
        )
      end
      button(type: "submit", class: "ui-button") { "Search" }
    end
  end

  def results_list
    div(class: "space-y-4") do
      p(class: "text-sm text-muted") { "#{@results.length} results for \"#{@query}\"" }
      @results.each do |result|
        result_card(result)
      end
    end
  end

  def result_card(result)
    item = result.zotero_item
    chunk = result.chunk
    relevance = ((1.0 - result.distance) * 100).round

    div(class: "ui-card p-4 space-y-2") do
      div(class: "flex justify-between items-start") do
        div do
          h3(class: "font-semibold text-body") { item.title || "Untitled" }
          if authors_text(item).present?
            p(class: "text-sm text-muted") { authors_text(item) }
          end
        end
        span(class: "text-xs text-muted whitespace-nowrap ml-2") { "#{relevance}% match" }
      end

      div(class: "text-sm text-body/80 bg-surface-raised p-3 rounded") do
        if chunk.section_heading.present?
          span(class: "font-semibold text-xs text-muted") { "[#{chunk.section_heading}] " }
        end
        plain chunk.content.truncate(300)
      end

      div(class: "flex items-center gap-3 text-xs") do
        if item.item_type.present?
          span(class: "text-muted") { item.item_type }
        end

        a(href: zotero_link(item), class: "text-accent hover:underline", target: "_blank") do
          plain "Open in Zotero"
        end
      end
    end
  end

  def no_results
    div(class: "text-center py-12 text-muted") do
      p { "No relevant items found for \"#{@query}\"." }
      p(class: "text-sm mt-2") { "Try a different query or ensure your library has been synced and processed." }
    end
  end

  def empty_state
    has_embeddings = DocumentChunk.joins(:zotero_item)
      .where(zotero_items: { account_id: Current.account&.id })
      .where.not(embedding_model: nil)
      .exists?

    div(class: "text-center py-12 text-muted") do
      if has_embeddings
        p { "Enter a query to search your library." }
        p(class: "text-sm mt-2") { "Ask a question in natural language — semantic search finds relevant papers by meaning, not just keywords." }
      else
        p { "Your library hasn't been processed yet." }
        p(class: "text-sm mt-2") do
          plain "Run the "
          a(href: pipeline_path, class: "text-accent hover:underline") { "sync pipeline" }
          plain " to start searching."
        end
      end
    end
  end

  def authors_text(item)
    return "" unless item.authors_json.present?
    authors = JSON.parse(item.authors_json) rescue []
    authors.map { |a| [ a["firstName"], a["lastName"] ].compact.join(" ") }.join(", ")
  end

  def zotero_link(item)
    "zotero://select/items/#{item.zotero_key}"
  end
end
