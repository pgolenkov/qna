module VotesHelper
  def vote_link(text, votable, status)
    link_to text, votes_path(votable_type: votable.class.to_s.underscore, votable_id: votable.id, status: status), remote: true, method: :post, data: { type: :json }, class: "vote-link"
  end
end
