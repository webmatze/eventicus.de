class Avatar < ActiveRecord::Base
  belongs_to :user
  
  has_attachment  :content_type => :image,
                  :storage      => :file_system,
                  :max_size     => 500.kilobytes,
                  :risize_to    => '128x128>',
                  :thumbnails   => {
                    :normal => '64x64>',
                    :small  => '32x32>',
                    :mini   => '16x16>'
                  }
                  
  validates_as_attachment
end