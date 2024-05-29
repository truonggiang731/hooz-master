# frozen_string_literal: true

class User < ApplicationRecord
  include Notificationable

  has_secure_password

  has_one_attached :avatar

  has_one :verification, dependent: :destroy
  has_many :sessions, dependent: :delete_all
  has_many :favorites, dependent: :delete_all
  has_many :reading_chapters, dependent: :delete_all
  has_many :purchases, dependent: :delete_all

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: true
  validates :email,
            presence: true

  REQUIRED_ATTRIBUTES = %i[email password].freeze

  def current_plan
    purchases.find_by('NOW()::TIMESTAMP > effective_date::TIMESTAMP AND NOW()::TIMESTAMP < expiry_date::TIMESTAMP')
  end

  class << self
    def filter(params)
      users = all.order(id: :asc)

      if params[:query].present?
        query = params[:query].strip

        users = users.where('email ILIKE ?', "%#{query}%", "%#{query}%")
      end

      if params[:sort_by].present?
        sort_by = params[:sort_by].split(',').map { |t| t.split('-') }
        sort_by = sort_by.select { |t| t[0].in?(%w[email created_at]) && t[1].in?(%w[asc desc]) }
        sort_by = sort_by.map { |t| "users.#{t[0]} #{t[1]}" }

        users = categories.order(sort_by.join(', '))
      end

      users
    end
  end
end
