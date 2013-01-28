# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :trackable,
    :validatable, :encryptable, :encryptor => :sha1

  attr_accessible :login, :name, :email, :password, :password_confirmation, :remember_me

  belongs_to :department

  protected
   def password_required?
     new_record? || destroyed? || password.present? || password_confirmation.present?
   end
end
