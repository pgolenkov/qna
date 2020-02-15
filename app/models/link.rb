class Link < ApplicationRecord
  GIST_URL = 'gist.github.com'
  RAW_GIST_URL = 'gist.githubusercontent.com'

  belongs_to :linkable, polymorphic: true
  validates :name, presence: true
  validates :url, presence: true, url: { no_local: true }

  def gist?
    URI(url).host == GIST_URL
  end

  def gist_raw
    return unless gist?

    raw_url = url.gsub(GIST_URL, RAW_GIST_URL) + '/raw/'
    response = HTTParty.get(raw_url)

    response.code == 200 ? response.body : 'Wrong gist link'
  end
end
