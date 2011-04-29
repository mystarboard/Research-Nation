class ProfilesController < ApplicationController

  before_filter :set_tags, :only => ["company", "individual", "view_profile_list", "edit_individual_profile", "edit_company_profile"]

  def company
    @profile = Profile.new
  end

  def individual
    @profile = Profile.new
  end

  def view_profile_list
    @profiles = []

    users = User.find :all, :conditions => ['user_type like ? ', "%Seller%"]
    users.each do |user|
      @profiles.push(user.profile) unless user.profile.blank? || user.profile.is_edited==false
    end
    @industry_focus.push("All")
  end

  def profile_page
    @profile = Profile.find params[:id]
    @interests = @profile.interested_in.split(",") unless @profile.interested_in.blank?
  end

  def create
    profile = session[:profile].blank? ? Profile.new(params[:profile]) : session[:profile]
    key_individual = session[:key_individual].blank? ? KeyIndividual.new(params[:key_individual]) : session[:key_individual]

    unless logged_in?
      session[:key_individual] = key_individual
      session[:profile] = profile
      return redirect_to :controller => 'users'  , :action => 'register'
    end

    profile.user_id = session[:user]
    if profile.save
      key_individual = KeyIndividual.new
      key_individual.profile_id = profile.id
      key_individual.save

      session[:profile] = nil
      session[:key_individual] = nil

      key_individual.profile_id = profile.id
      key_individual.save
      return redirect_to :controller => 'users', :action => 'profile'
    end

  end

  def update
    profile = Profile.find params[:id]
    key_individual = profile.key_individual
    profile.update_attributes(params[:profile])
    profile.update_attribute( :is_edited, true )
    key_individual.update_attributes params[:key_individual] unless key_individual.blank?
    flash[:notice] = "Your Information was updated successfully"
    return redirect_to :controller => 'users', :action => 'profile', :id => profile.user.id
  end

  def types
    render :text => "company\nindividual"
  end

  def edit_individual_profile
    @profile = Profile.find params[:id]
    @key_individual = @profile.key_individual unless @profile.key_individual.blank?
  end

  def edit_company_profile
    @profile = Profile.find params[:id]
    @key_individual = @profile.key_individual unless @profile.key_individual.blank?
  end

  def delete
    profile = Profile.find params[:id]
    profile.destroy
    return redirect_to :controller => 'admin', :action => 'dashboard'
  end

  def search_results
    choices = params[:choices].split(",") unless params[:choices].blank?
    @profiles = []

    conditions   = ""
    conditions  += "industry_focus = '#{params[:industry].strip}'" if params[:industry].downcase != "all"
    if conditions.length > 0 && params[:country].strip.downcase != "all"
      conditions  += " and country = '#{params[:country].strip}' "
    elsif params[:country].downcase != "all"
      conditions  += "country = '#{params[:country].strip}' "
    end
    if conditions.length > 0 && params[:profile_type].strip.downcase != "all"
      conditions  += " and profile_type = '#{params[:profile_type].strip}' "
    elsif params[:profile_type].strip.downcase != "all"
      conditions  += "profile_type = '#{params[:profile_type].strip}' "
    end
    @profile_list = Profile.find :all, :conditions => conditions, :order => 'created_at DESC'
    @profiles = []
    unless choices.blank?
      @profile_list.each do |profile|
        choices.each do |choice|
          if profile.interested_in.split(",").include?(choice)
            @profiles << profile
            break
          end
        end
      end
    else
      if conditions.length > 0
        conditions  +=  "and interested_in IS NULL"
      else
        conditions  =  "interested_in IS NULL"
      end
      @profiles = (Profile.find :all, :conditions => conditions, :order => 'created_at DESC')
    end
    @profiles.flatten!
   render :partial => 'profiles'
  end

  def send_message_to_profile
    profile = Profile.find params[:id]
    message = Message.new
    message.subject = params["subject"]
    message.body = params[:message]
    message.sender = User.find session[:user]
    message.recipient = profile.user
    if message.save
      return render :text => "<p class='flash'>Thank you! Your message has been sent</p>"
    else
      render :text => "Hmm. Something seems to be wrong...let me look into it"
    end
  end

private
  def set_tags
    @research_type = ["Advertising Research", "Attitude & Usage Research", "Brand Research", "Business to Business", "Competitive Intelligence", "Concept/Positioning", "Consumer Research", "Corporate Image/Identity", "Customer Satisfaction", "Employee Surveys", "Demographic Research", "International (i.e. non-US)", "Legal Research", "Marketing Research", "Media Research", "Modeling & Predictive Research", "Mystery Shopping", "New Product Research", "Packaging Research", "Price Research", "Problem Detection", "Product Research", "Evaluation Studies", "Psychological Research", "Public Opinion", "Recruiting Research", "Retail Research", "Secondary Research", "Seminars/ Training", "Strategic Research", "Technology Evaluations", "Website Usability"]
    @industry_focus = ["All", "Acquisitions", "Ad Agencies", "Agriculture", "Airlines", "Alcoholic Beverages", "Clothing", "Automotive", "Beverages", "Industrial", "Candy", "Gambling", "Chemicals", "Media & Communications", "Tech", "Construction", "Consumer Durables", "Consumer Services", "Cosmetics", "Demographics", "Education", "Electronics", "Entertainment", "Environment", "Fitness", "Fashion", "Financial Services & Investing", "Foods", "Gay & Lesbian", "Government", "Health Care", "Legal", "Couponing", "Military", "Non-Profits", "Packaged Goods", "Pets", "Oil & Gas", "Public Relations", "Real Estate", "Religion", "Retail", "Small Businesses", "Startups", "Sports", "Tobacco", "Toys", "Transportation", "Travel", "Utilities/Energy"]
  end

end
