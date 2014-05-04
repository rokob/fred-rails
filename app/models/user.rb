class User < ActiveRecord::Base
  has_many :friendships
  has_many :friends, -> { Friendship.friend_scope }, :through => :friendships
  has_many :friend_requests, -> { Friendship.requested_scope }, :through => :friendships, :source => :friend
  has_many :pending_requests, -> { Friendship.pending_scope }, :through => :friendships, :source => :friend

  before_save { self.email = email.downcase }
  before_create :create_remember_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+(?<!\.)\.[a-z]+\z/i

  validates :name,  presence:   true,
                    length:     { maximum: 50 }
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, length: { minimum: 6 }

  def User.new_remember_token
    SecureRandom.urlsafe_base64(20)
  end

  def User.hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def User.all_with_friends_paginated(user, params)
    # this custom query is a greater than 300% improvement
    sql = "SELECT users.*,
          CASE
            WHEN users.id IN
              (SELECT friendships.friend_id FROM friendships WHERE status = ? AND friendships.user_id = ?)
              THEN '1'
            ELSE '0'
          END as private_is_friends,
          CASE
            WHEN users.id IN
              (SELECT friendships.friend_id FROM friendships WHERE status IN (?) AND friendships.user_id = ?)
              THEN '0'
            WHEN users.id = ? THEN '0'
            ELSE '1'
          END as private_is_requestable
          FROM users"
    User.paginate_by_sql([sql,
                          Friendship::ACCEPTED,
                          user.id,
                          Friendship::NOT_REQUESTABLE_STATUSES,
                          user.id,
                          user.id
                         ], page: params[:page], per_page: params[:per_page])
  end

  def is_friends_with_current_user?
    private_is_friends == '1' if self.respond_to?(:private_is_friends)
  end

  def is_requestable_by_current_user?
    private_is_requestable == '1' if self.respond_to?(:private_is_requestable)
  end

  def friends?(other_user)
    friends.find_by(id: other_user.id)
  end

  private
    def create_remember_token
      self.remember_token = User.hash(User.new_remember_token)
    end
end
