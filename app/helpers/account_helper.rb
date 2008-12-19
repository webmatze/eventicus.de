module AccountHelper
  def avatar_for(user, size = nil) 
    if user.avatar 
      avatar_image = size.nil? ? user.avatar.public_filename : user.avatar.public_filename(size) 
      image_tag(avatar_image)
    else 
      if size.nil?
        image_tag("default-avatar.png")         
      else
        image_tag("default-avatar-#{size}.png") 
      end
    end 
  end 
end
