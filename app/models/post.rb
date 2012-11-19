class Post < ActiveRecord::Base
  has_one :user
  has_one :icon
  
  scope :by_month, (lambda do |month|
    where("extract(month from created_at) = ?", month) unless month.blank?
  end)
  
  scope :by_date, (lambda do |year, month, day|
    where("extract(year from created_at) = ? AND extract(month from created_at) = ? AND extract(day from created_at) = ?", year, month, day)
  end)
end