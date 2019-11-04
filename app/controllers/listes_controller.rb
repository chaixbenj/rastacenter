class ListesController < ApplicationController
  before_action :require_login

  
  def index
    liste_id = (params[:liste_id] != nil ? params[:liste_id] : flash[:liste_id]).to_s
    @name = params[:sname].to_s
    if @name != ""
      @listes = Liste.where("domaine_id = #{@domaine} and name like '%#{@name}%'").order(:name).all
    else  
      @listes = Liste.where("domaine_id = #{@domaine}").order(:name).all
    end 
  
	@message, @OK = Commun.set_message(flash[:ko])
    if liste_id != ""
     @liste = Liste.where(:id => liste_id).first
      if @liste != nil
        @listevalues = ListeValue.where(:liste_id => liste_id).all.order(:value)
      end 
    end
  end  
    
  def getone
    flash[:liste_id] = params[:liste_id].to_s
    redirect_to controller: 'listes', action: 'index'
  end
   
  def update
    liste_id = params[:liste_id].to_s
    if @can_manage_liste == 1
      if params[:delete] != nil
        liste = Liste.where(:id => liste_id).first
        if liste != nil 
          liste.destroy
        end
      end

      if params[:valid] != nil
        liste = Liste.where(:id => liste_id).first
        flash[:ko] = 1
        if liste != nil
          flash[:liste_id] = liste.id
          if params[:code].to_s == "" or Liste.where("domaine_id = #{@domaine} and code = '#{params[:code].to_s}' and id != #{liste_id}").first == nil
            if liste.is_deletable == 1
              liste.name = params[:name].to_s
              liste.description = params[:desc].to_s
              liste.code = params[:code].to_s
              liste.save
            end
            nbvalues = params[:nbvalue].to_s.to_i
            for val in 1..nbvalues
              varvalid = params["varvalueid#{val}"]
              varval = params["varvalue#{val}"].to_s
              if varvalid == nil and varval.gsub(" ","") != ""
                listevalue = ListeValue.new
                listevalue.domaine_id = @domaine
                listevalue.is_modifiable = 1
                listevalue.liste_id = liste_id
                listevalue.value = varval
                listevalue.save
              else
                if varvalid != nil
                  listevalue = ListeValue.where(:id => varvalid.to_i).first
                  if varval.gsub(" ","") == ""
                    if listevalue != nil and listevalue.is_modifiable == 1
					           begin
                      listevalue.destroy
                      if liste.code == "WKF_STATUS"
                        Node.where(:domaine_id => @domaine, :obj_type => 'startworkflow', :obj_id => varvalid.to_i).update_all(:obj_id => nil, :name => t('ecr_sheet.cliquez_pour_saisir'))
                        Node.where(:domaine_id => @domaine, :obj_type => 'status', :obj_id => varvalid.to_i).update_all(:obj_id => nil, :name => t('ecr_sheet.cliquez_pour_saisir'))
                        Node.where(:domaine_id => @domaine, :obj_type => 'endpoint', :obj_id => varvalid.to_i).update_all(:obj_id => nil, :name => t('ecr_sheet.cliquez_pour_saisir'))
						            KanbanStatus.where(:domaine_id => @domaine, :status_id => varvalid.to_i).delete_all
					            end
					            rescue 
						            flash[:ko] = 8
                    end
					       end
                  else
                    listevalue.value = varval
                    listevalue.save
                    if liste.code == "WKF_STATUS"
                      Node.where(:domaine_id => @domaine, :obj_type => 'startworkflow', :obj_id => listevalue.id).update_all(:name => varval)
                      Node.where(:domaine_id => @domaine, :obj_type => 'status', :obj_id => listevalue.id).update_all(:name => varval)
                      Node.where(:domaine_id => @domaine, :obj_type => 'endpoint', :obj_id => listevalue.id).update_all(:name => varval)
					            KanbanStatus.where(:domaine_id => @domaine, :status_id => listevalue.id).update_all(:status_name => varval)
                    end
                  end
                end
              end
            end 
          else
            flash[:ko] = 7
          end
          
          end     
        end
      end  
      redirect_to controller: 'listes', action: 'index'  
    end
  
  
    def new
      if @can_manage_liste == 1
        liste = Liste.new
        liste.name =  params[:namec]
        liste.domaine_id = @domaine
        liste.is_deletable = 1
        liste.save
        flash[:liste_id] = liste.id
        redirect_to controller: 'listes', action: 'index'
        end
      end  
  
    end
