# frozen_string_literal: true

class Post < ApplicationRecord
  validates :uri, :repo, presence: true
end
