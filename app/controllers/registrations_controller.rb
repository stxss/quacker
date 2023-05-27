class RegistrationsController < Devise::RegistrationsController

  def create
    super
    if resource.save
      resource.create_account
    end
  end

end
