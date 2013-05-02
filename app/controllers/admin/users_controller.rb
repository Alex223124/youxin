class Admin::UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_users_path, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def excel_importor
    begin
      excel_praser = Youxin::ExcelPraser.new(params[:excel].tempfile).process
    rescue Youxin::ExcelPraser::InvalidFileType => e
      redirect_to :back, alert: 'InvalidFileType'
      return
    end
    imported_user_array = []
    unimported_user_array = []
    excel_praser.user_array.each do |user_hash|
      user_hash[:password_confirmation] = user_hash[:password]
      user = User.new(user_hash)
      if user.save
        imported_user_array << user
      else
        unimported_user_array << user
      end
    end
    flash[:unimported_users] = unimported_user_array
    redirect_to admin_users_path, flash: { notice: 'Successfully created...' }
  end
end
