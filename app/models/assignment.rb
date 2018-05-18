class Assignment < ApplicationRecord
  belongs_to :user, primary_key: "userid", foreign_key: "userid"
  belongs_to :role
end
