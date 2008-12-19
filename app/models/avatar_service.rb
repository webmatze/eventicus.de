class AvatarService 
  attr_reader :user, :avatar 

  def initialize(user, avatar) 
    @user = user 
    @avatar = avatar 
  end 

  def save 
    return false unless valid? 
    begin 
      User.transaction do 
        if @avatar.new_record? 
          @user.avatar.destroy if @user.avatar 
          @avatar.user = @user 
          @avatar.save! 
        end 
        @user.save! 
        true 
      end 
    rescue 
      false 
    end 
  end 
  
  def update_avatar(avatar_file)
    unless avatar_file.blank?
      @avatar = Avatar.new(:uploaded_data => avatar_file)
    end
    save
  end

  def valid? 
    @user.valid? && @avatar.valid? 
  end 

end 
