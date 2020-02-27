module Attachable
  extend ActiveSupport::Concern

  included do
    has_many_attached :files
  end

  def files_as_json
    files.map do |file|
      {
        id: file.id,
        filename: file.filename,
        url: Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
      }
    end
  end
end
