# frozen_string_literal: true

require 'rails_helper'

describe About do

  describe 'stats cache' do
    include_examples 'stats cachable'
  end

end
