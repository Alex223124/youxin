# encoding: utf-8

# Provides a base class for Admin controllers to subclass
#
# # Automatically sets the layout and ensures an administrator is logged in
class Admin::ApplicationController < ApplicationController
  layout 'admin'
  before_filter :authenticate_admin!

  protected
  def authenticate_admin!
    raise Youxin::NotFound.new('纳尼') unless Youxin.config.admin_phones.include?(current_user.phone)
  end
end

