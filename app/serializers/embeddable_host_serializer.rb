# frozen_string_literal: true

class EmbeddableHostSerializer < ApplicationSerializer
  TO_SERIALIZE = %i[id host allowed_paths class_name category_id]

  attributes *TO_SERIALIZE

  TO_SERIALIZE.each { |attr| define_method(attr) { object.public_send(attr) } }
end
