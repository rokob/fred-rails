class User < ActiveRecord::Base
  has_many :friendships
  has_many :friends, -> { Friendship.friend_scope }, :through => :friendships
  has_many :friend_requests, -> { Friendship.requested_scope }, :through => :friendships, :source => :friend
  has_many :pending_requests, -> { Friendship.pending_scope }, :through => :friendships, :source => :user

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

  def friends?(other_user)
    friends.find_by(id: other_user.id)
  end

  private
    def create_remember_token
      self.remember_token = User.hash(User.new_remember_token)
    end
end
