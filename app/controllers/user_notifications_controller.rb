class UserNotificationsController < ApplicationController
  before_action :require_login

  
  def index
	@popup = "true"
	me = User.where(:id => @my_user_id).first 
    @notifications = UserNotification.where(:domaine_id => me.domaine_id, :user_id => me.id).all.order("link_notif_id DESC, id DESC")
	if @username != "superadmin"
		@all_users = User.select("distinct otherusers.*")
					.joins("INNER JOIN userprojects as myprojects on myprojects.domaine_id = users.domaine_id and myprojects.user_id = users.id")
					.joins("INNER JOIN userprojects as otheruserprojects on otheruserprojects.domaine_id = users.domaine_id and otheruserprojects.project_id = myprojects.project_id")
					.joins("INNER JOIN users as otherusers on otheruserprojects.domaine_id = otherusers.domaine_id and otheruserprojects.user_id = otherusers.id")
					.where("users.id =  #{@my_user_id}").all.order("otherusers.username")
	else
		@all_users = User.where(:is_admin => 1).all.order("username")
	end
  end  

  def new
	destinataires = params[:checkedids].to_s.split(";")
	notification = params[:notif].to_s
	link_notif_id = params[:notif_id].to_s
	listedest = ""
	mydomaine = @domaine
	
	notifinit = UserNotification.new(:domaine_id => mydomaine, :user_id => @my_user_id, :sent_by_id => @my_user_id, :sent_by => @connecteduser, :message => notification, :lu => 2, :link_notif_id => link_notif_id)
	notifinit.save
	if link_notif_id == "" 
		link_notif_id = notifinit.id
	end

	if params[:allusersalldomaine] != nil
		destinataires = User.all
		listedest = "Everybody"
		status_notif = 0
		destinataires.each do |destinataire|
			if destinataire.id.to_s != @my_user_id.to_s  
				notif = UserNotification.new(:domaine_id => destinataire.domaine_id, :user_id => destinataire.id, :sent_by_id => @my_user_id, :sent_by => "contact_alfyft", :message => notification, :lu => status_notif, :link_notif_id => link_notif_id)
				notif.save
			else
				mydomaine = destinataire.domaine_id
			end
		end
	else
		destinataires.each do |destinataire|
			if destinataire != ""
			userdest = User.where(:id => destinataire).first
			if userdest == nil then
				userdest = User.where(:login => destinataire).first
			end
			if userdest != nil
				status_notif = 0
				if userdest.id.to_s != @my_user_id.to_s  
					listedest += userdest.username + "; "
					notif = UserNotification.new(:domaine_id => userdest.domaine_id, :user_id => userdest.id, :sent_by_id => @my_user_id, :sent_by => @connecteduser, :message => notification, :lu => status_notif, :link_notif_id => link_notif_id)
					notif.save
				end
			end
			end
		end
	end

	notifinit.message = listedest.gsub("superadmin", "contact_alfyft") + "<br>" + notification
	notifinit.link_notif_id = link_notif_id
	notifinit.save
	
    redirect_to controller: 'user_notifications', action: 'index'
  end

  def update
	notif_id = params[:notif_id]
	retour = ""
	if notif_id != nil
		notif = UserNotification.where(:id =>  notif_id).first
		if notif != nil
			if params[:delete] != nil
				firstsonnotif = UserNotification.where(:domaine_id => @domaine, :link_notif_id =>  notif.id).first
				if firstsonnotif != nil
					UserNotification.where(:domaine_id => @domaine, :link_notif_id =>  notif.id).update_all(:link_notif_id =>  firstsonnotif.id)
				end
				notif.destroy
				retour = "deleted;#{notif_id}"
			end
			if params[:seen] != nil
				notif.lu = 1
				notif.save
				retour = "seen;#{notif_id}"
			end
		end
	end
    render html: retour
  end  
  


  
  
  

end
