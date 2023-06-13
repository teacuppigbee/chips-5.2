class Movie < ActiveRecord::Base
  def self.with_ratings(ratings_list)
    if ratings_list.present?
      where(rating: ratings_list.flatten.map { |rating| rating.to_s.upcase })
    else
      all
    end
  end


  def self.all_ratings
    pluck(:rating).uniq
  end
end
