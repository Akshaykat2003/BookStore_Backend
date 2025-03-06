class User < ApplicationRecord

has_secure_password

validates :name

end
