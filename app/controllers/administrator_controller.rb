# frozen_string_literal: true

class AdministratorController < ApplicationController
  include LazyLookup

  before_action :authenticate!, :must_be_admin!
end
