# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include ArelHelpers::ArelTable

  primary_abstract_class
end
