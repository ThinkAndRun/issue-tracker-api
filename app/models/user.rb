class User < ApplicationRecord
  has_secure_password

  before_validation :downcase_email

  validates :name, :email, presence: true
  validates :email, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum:6 },
                       confirmation: true,
                       on: :create

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
