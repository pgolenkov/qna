# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all

    if user
      can :create, [Question, Answer, Comment]

      can [:update, :destroy], [Question, Answer, Vote], user_id: user.id

      can :destroy, ActiveStorage::Attachment, record: { user_id: user.id }
      can :destroy, Link, linkable: { user_id: user.id }

      can :make_best, Answer, question: { user_id: user.id }

      can :create_vote, [Question, Answer] do |votable|
        votable.user_id != user.id
      end
    end
  end
end
