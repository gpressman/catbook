class Cat < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: true, length: { in: 2..255 }
  validates :email, presence: true, uniqueness: true,
   format: { with: /[a-zA-Z0-9.+-_]+@\w+.\w+/, message: "invalid email format" }



  scope :visible, -> { where(visible: true) }
  scope :hidden,  -> { where(visble: false) }
  scope :public_info,  -> { select(:id, :name, :email, :sign_in_count, :breed)}
  # More info
  # http://guides.rubyonrails.org/association_basics.html
  # https://www.railstutorial.org/book/frontmatter
  # http://apidock.com/rails/ActiveRecord/Associations/ClassMethods/has_many
  # http://stackoverflow.com/questions/5856838/scope-with-join-on-has-many-through-association
  has_many :follower_relations
  has_many :followed_relations, class_name: "FollowerRelation", foreign_key: "followed_cat_id"

  has_many :followers,    -> { visible }, through: :follower_relations, source: :followed
  has_many :followed_by,  -> { visible }, through: :followed_relations, source: :cat



  def localized_birthday
    return '--' unless @birthday
    return localize_date @birthday
  end


end