class SearchesController < ApplicationController
  def show
    classes = params[:resources].to_a.compact.map(&:classify).map(&:constantize)
    query = ThinkingSphinx::Query.escape(params[:query] || '')

    @records = if classes.present?
      query.present? ? ThinkingSphinx.search(query, classes: classes) : []
    end
  end
end
