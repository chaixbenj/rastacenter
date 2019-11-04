class ReleasesController < ApplicationController
  before_action :require_login

  
  def index
    release_id = (params[:release_id] != nil ? params[:release_id] : flash[:release_id]).to_s
    cycle_id = (params[:cycle_id] != nil ? params[:cycle_id] : flash[:cycle_id]).to_s
    campain_id = (params[:campain_id] != nil ? params[:campain_id] : flash[:campain_id]).to_s

    @releasecyclecampains = Project
    .select("projects.id as project_id, projects.name as project_name, releases.id as release_id, releases.name as release_name, cycles.id as cycle_id, cycles.name as cycle_name, campains.id as campain_id, campains.name as campain_name, campains.private as campain_private")
    .joins("INNER JOIN userprojects on userprojects.domaine_id = projects.domaine_id and userprojects.project_id = projects.id")
    .joins("LEFT OUTER JOIN releases on  releases.domaine_id = projects.domaine_id and releases.project_id = projects.id")
    .joins("LEFT OUTER JOIN cycles on  cycles.domaine_id = releases.domaine_id and cycles.release_id = releases.id")
    .joins("LEFT OUTER JOIN campains on  campains.domaine_id = cycles.domaine_id and campains.cycle_id = cycles.id and (campains.private = 0 or campains.owner_user_id = #{@my_user_id})")
    .where("projects.domaine_id = #{@domaine} and userprojects.user_id = #{@my_user_id}" ).order("projects.id, releases.id, cycles.id, campains.id").all
 
    @message = nil
    
    @message, @OK = Commun.set_message(flash[:ko])

    if release_id != ""
      @release = Release.where(:id => release_id).first
    end
    if cycle_id != ""
      @cycle = Cycle.where(:id => cycle_id).first
    end
    if campain_id != ""
      @campain = Campain.where(:id => campain_id).first
    end
  end  
    
  def getone
    flash[:release_id] = params[:release_id].to_s
    flash[:cycle_id] = params[:cycle_id].to_s
    flash[:campain_id] = params[:campain_id].to_s
    redirect_to controller: 'releases', action: 'index'
  end
   
  def update
    if @can_manage_release == 1
      release_id = params[:elem_id]
      if params[:delete] != nil
        release = Release.where(:id => release_id).first
        flash[:ko] = 99
        if release != nil
          release.destroy
          flash[:ko] = 1
        end
      end

      if params[:valid] != nil
        release = Release.where(:id => release_id).first
        flash[:ko] =1
        if release != nil
          release.name = params[:pname].to_s
          release.description = params[:pdesc].to_s
          release.string1 = params[:pstring1].to_s
          release.value1 = params[:pvalue1].to_s
          release.string2 = params[:pstring2].to_s
          release.value2 = params[:pvalue2].to_s
          release.string3 = params[:pstring3].to_s
          release.value3 = params[:pvalue3].to_s
          release.string4 = params[:pstring4].to_s
          release.value4 = params[:pvalue4].to_s
          release.string5 = params[:pstring5].to_s
          release.value5 = params[:pvalue5].to_s
          release.string6 = params[:pstring6].to_s
          release.value6 = params[:pvalue6].to_s
          release.string7 = params[:pstring7].to_s
          release.value7 = params[:pvalue7].to_s
          release.string8 = params[:pstring8].to_s
          release.value8 = params[:pvalue8].to_s
          release.string9 = params[:pstring9].to_s
          release.value9 = params[:pvalue9].to_s
          release.string10 = params[:pstring9].to_s
          release.value10 = params[:pvalue9].to_s
          release.save
          flash[:ko] = 1
          
        end     
        flash[:release_id] = release.id
      end
    else
      flash[:ko] = 99
    end
    redirect_to controller: 'releases', action: 'index'
  end
  
  def new
    if @can_manage_release == 1
      if params[:project_id] != nil and Project.where(:id => params[:project_id]).first != nil
        release = Release.new
        release.name =  t('ecr_release.nouvelle_release')
        release.domaine_id = @domaine
        release.project_id = params[:project_id]
        release.save
        flash[:release_id] = release.id
      end
    end
    redirect_to controller: 'releases', action: 'index'
  end  
  
end
