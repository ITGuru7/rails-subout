class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.has_role? :admin
        can :manage, :all
    end
    if user.has_role? :member
        can [:read, :create, :update, :destroy] [Bid, Event, Favorite, Opportunity]
    end
    if user.has_role? :guest
        can :read, Opportunity
        can [:read, :create, :update, :destroy] [Bid]
    end
  end
end
