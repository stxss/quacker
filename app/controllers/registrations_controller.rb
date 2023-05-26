class RegistrationsController < Devise::RegistrationsController

  def create
    super
    resource.create_account
  end

end
