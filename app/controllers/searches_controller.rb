class SearchesController < ApplicationController
  def show
    @questions = params[:query].present? ? Question.search(params[:query]) : []
  end
end
