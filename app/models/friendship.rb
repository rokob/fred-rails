class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => 'User'
  validates :user_id, presence: true
  validates :friend_id, presence: true

  PENDING   = 'pending'
  REQUESTED = 'requested'
  ACCEPTED  = 'accepted'
  REJECTED  = 'rejected'
  CANCELED  = 'canceled'
  DELETED   = 'deleted'
  BLOCKED   = 'blocked'
  STATUSES  = [PENDING, REQUESTED, ACCEPTED, REJECTED, CANCELED, DELETED, BLOCKED]
  NOT_REQUESTABLE_STATUSES = [PENDING, REQUESTED, ACCEPTED, BLOCKED]

  INCLUDE_FRIENDSHIP_ID_SQL = "users.*, friendships.id as friendship_id"

  class << self
    def friend_scope
      where(status: ACCEPTED).select(INCLUDE_FRIENDSHIP_ID_SQL)
    end

    def pending_scope
      where(status: PENDING).select(INCLUDE_FRIENDSHIP_ID_SQL)
    end

    def requested_scope
      where(status: REQUESTED).select(INCLUDE_FRIENDSHIP_ID_SQL)
    end

    def blocked_scope
      where(status: BLOCKED).select(INCLUDE_FRIENDSHIP_ID_SQL)
    end

    def not_requestable_scope
      where(status: NOT_REQUESTABLE_STATUSES)
    end

    def between(user, friend)
      find_by(user: user, friend: friend)
    end

    def request(user, friend)
      unless Friendship.invalid_request?(user, friend)
        transaction do
          create(user: user, friend: friend, status: PENDING)
          create(user: friend, friend: user, status: REQUESTED)
        end
      end
    end

    def invalid_request?(user, friend)
      user == friend or Friendship.not_requestable_scope.exists?(user: user, friend: friend)
    end

    def actionable_request?(user, friend)
      Friendship.pending_scope.exists?(user: user, friend: friend) and Friendship.requested_scope.exists?(user: friend, friend: user)
    end

    def accept(friend, user)
      return unless actionable_request?(user, friend)
      transaction_action(user, friend, ACCEPTED)
    end

    def reject(friend, user)
      return unless actionable_request?(user, friend)
      transaction_action(friend, user, REJECTED)
    end

    def cancel(user, friend)
      return unless actionable_request?(user, friend)
      transaction_action(user, friend, CANCELED)
    end

    def unfriend(user, friend)
      if Friendship.friend_scope.exists?(user: user, friend: friend)
        transaction_action(user, friend, DELETED)
      end
    end

    private
      def transaction_action(user, friend, status)
        transaction do
          action_time = Time.now
          one_side_action(user, friend, status, action_time)
          one_side_action(friend, user, status, action_time)
        end
      end

      def one_side_action(user, friend, status, status_changed_at)
        friendship = find_by(user: user, friend: friend)
        friendship.status = status
        #friendship.status_changed_at = status_changed_at
        friendship.save!
      end
  end
end
