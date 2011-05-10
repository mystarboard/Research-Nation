class AdminController < ApplicationController

  before_filter :redirect_to_admin_login, :get_counts

  def dashboard
    redirect_to :action => "users"
  end

  def users
    @users = User.paginate :page => params[:page], :order => 'created_at DESC'
  end

=begin
  def experts
    @experts= User.paginate :page => params[:page], :order => 'created_at DESC', :conditions => ['is_expert = ?', true]
  end
=end

  def posts
    @posts = Resource.paginate :page => params[:page], :order => 'created_at DESC'
  end

  def mail_chimp_list
    @members = get_mailchimp_list_members
  end

  def admin_rights
    @users = User.paginate :page => params[:page], :order => 'created_at DESC'
  end

  def see_authentications
    @users =  User.find :all, :conditions => ['facebook_uid > ?', 0 ]
  end

  def manage_users
    @users = User.paginate :page => params[:page]
  end

  def change_admin_status
    user = User.find(:first, :conditions => ["id = ?", params[:user_id]])
    return render :partial => "is_admin_field", :locals => {:user => user}
  end

  def profiles
    @profiles = Profile.find :all, :order => 'created_at DESC'
  end

  def messages
    @messages = (Message.find_all_by_recipient_id current_user.id)
  end

  def seller_payments
    @users = User.paginate  (:conditions => ["id in (?)", Resource.sellers_with_paid_resources.collect(&:user_id)],
                            :page => params[:page])
  end

  def detailed_user_payments
    @user = User.find params[:user_id]
  end

  def pay_pending_payments
    user = User.find params[:user_id]
    date= params[:date].delete("#").split("-")
    year, month, day = date[0], date[1], date[2]

    time = Date.new(Integer(year), Integer(month)).to_time
    earnings = user.pay_for_pending_orders_within_date(time, time.end_of_month)
    UserMailer.deliver_payment_sent_email(user, time, time.end_of_month, earnings)

    return render :text => "success"
  end

private
  def get_counts
    session[:members_count] = get_mailchimp_list_members.count if session[:members_count].blank?
    @resources_count = Resource.count
    @users_count = User.count
    @admin_count = (User.find_all_by_is_admin true).count
    @members_count = session[:members_count]
    @experts_count = (User.find_all_by_is_expert(true)).count
    @profiles_count = Profile.count
    @messages_count = (Message.find_all_by_recipient_id current_user.id).count
  end

end
