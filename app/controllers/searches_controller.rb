class SearchesController < ApplicationController
  def show
    classes = params[:resources].to_a.compact.map(&:classify).map(&:constantize)

    @records = if classes.present?
      params[:query].present? ? ThinkingSphinx.search(params[:query], classes: classes) : []
    end
  end
end
