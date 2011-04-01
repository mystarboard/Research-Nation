class UsersController < ApplicationController

  before_filter :check_session, :except => [:register, :login, :create, :authenticate, :facebook_connect, :facebook_oauth_callback]

  def facebook_connect
    facebook_settings = YAML::load(File.open("#{RAILS_ROOT}/config/facebooker.yml"))
    redirect_to "https://graph.facebook.com/oauth/authorize?client_id=#{facebook_settings[RAILS_ENV]['application_id']}&redirect_uri=http://#{request.host}/users/facebook_oauth_callback&scope=email,offline_access,publish_stream"
  end

  def facebook_oauth_callback
    unless params[:code].nil?
      facebook_settings = YAML::load(File.open("#{RAILS_ROOT}/config/facebooker.yml"))
      callback = "http://#{request.host}/users/facebook_oauth_callback"

      url = URI.parse("https://graph.facebook.com/oauth/access_token?client_id=#{facebook_settings[RAILS_ENV]['application_id']}&redirect_uri=#{callback}&client_secret=#{facebook_settings[RAILS_ENV]['secret_key']}&code=#{CGI::escape(params[:code])}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')

      tmp_url = url.path+"?"+url.query
      request = Net::HTTP::Get.new(tmp_url)
      response = http.request(request)
      data = response.body
      access_token = data.split("=")[1]

      url = URI.parse("https://graph.facebook.com/me?access_token=#{CGI::escape(access_token)}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')
      tmp_url = url.path+"?"+url.query
      request = Net::HTTP::Get.new(tmp_url)
      response = http.request(request)
      user_data = response.body
      user_data_obj = JSON.parse(user_data)

      flash[:notice] = 'Facebook successfully connected.'

      valid_user = User.find_by_email(user_data_obj["email"])
      unless valid_user.blank?
        session[:user] = valid_user.id
        return redirect_to :controller => 'main', :action => 'post', :post_data => true
        redirect_to :controller => 'main', :action => 'index'
      else
        redirect_to :controller => 'users', :action => 'register', :first_name => user_data_obj["first_name"], :last_name => user_data_obj["last_name"], :email => user_data_obj["email"], :user_type => "facebook_user", :uid => user_data_obj["id"]
      end
    end
  end

  def register
    @user = User.new(params[:user])
    @user_type = params[:user_type]? params[:user_type] : "normal"
  end

  def login

  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user] = @user.id
      UserMailer.deliver_registration_email(@user.first_name, @user.last_name, @user.email)
      flash[:error] = ""
      flash[:success] = "Your account has been created successfully."
      return redirect_to :controller => 'main', :action => 'post' if session[:post]
      return redirect_to :controller => "main", :action => "index"
    end
    return render :action => 'register'
  end

  def edit
    @user = User.find_by_id(params[:id])
  end

  def update

    @user = User.find_by_id(params[:id])
    if @user.update_attributes params[:user]
      flash[:success] = "User details Updated"
      redirect_to :controller => 'main', :action => 'index'
    else
      flash[:error] = "Unable to update User Details"
      render :action => 'edit', :id => params[:id]
    end
  end

  def authenticate
    @user = User.new(params[:login])
    valid_user = User.find(:first,:conditions => ["email = ? and password = ?", @user.email, @user.password])
    if valid_user
      session[:user] = valid_user.id
      return redirect_to :controller => 'main', :action => 'post', :post_data => true
    else
      flash[:error] = "Invalid username/password"
      render :action => 'login'
    end
  end

  def check_session
    return redirect_to :action => 'login' unless session[:user]
  end

  def logout
    if logged_in?
      reset_session
      redirect_to :controller => 'main', :action=> 'index'
    end
  end

end
