class AssociateAccountsToUsers < ActiveRecord::Migration[7.0]
  def change
    User.find_each do |user|
      next if user.account.present?

      user.create_account
    end
  end
end
