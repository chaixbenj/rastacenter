class CyclesController < ApplicationController
  before_action :require_login

  
  def new
    if @can_manage_release == 1
      if params[:release_id] != nil 
        release = Release.where(:id => params[:release_id]).first 
        if release != nil
          cycle = Cycle.new
          cycle.name =  t('ecr_release.nouveau_cycle')
          cycle.domaine_id = @domaine
          cycle.release_id = params[:release_id]
          cycle.save
		  flash[:cycle_id] = cycle.id
        end	
      end
    end
	redirect_to controller: 'releases', action: 'index'
  end  


  def update
    if @can_manage_release == 1
      cycle_id = params[:elem_id]
      if params[:delete] != nil
        cycle = Cycle.where(:id => cycle_id).first
        flash[:ko] = 99
        if cycle != nil
          cycle.destroy
          flash[:ko] = 1
        end
      end

      if params[:valid] != nil
        cycle = Cycle.where(:id => cycle_id).first
        flash[:ko] =1
        if cycle != nil
          cycle.name = params[:pname].to_s
          cycle.description = params[:pdesc].to_s
          cycle.string1 = params[:pstring1].to_s
          cycle.value1 = params[:pvalue1].to_s
          cycle.string2 = params[:pstring2].to_s
          cycle.value2 = params[:pvalue2].to_s
          cycle.string3 = params[:pstring3].to_s
          cycle.value3 = params[:pvalue3].to_s
          cycle.string4 = params[:pstring4].to_s
          cycle.value4 = params[:pvalue4].to_s
          cycle.string5 = params[:pstring5].to_s
          cycle.value5 = params[:pvalue5].to_s
          cycle.string6 = params[:pstring6].to_s
          cycle.value6 = params[:pvalue6].to_s
          cycle.string7 = params[:pstring7].to_s
          cycle.value7 = params[:pvalue7].to_s
          cycle.string8 = params[:pstring8].to_s
          cycle.value8 = params[:pvalue8].to_s
          cycle.string9 = params[:pstring9].to_s
          cycle.value9 = params[:pvalue9].to_s
          cycle.string10 = params[:pstring9].to_s
          cycle.value10 = params[:pvalue9].to_s
          cycle.save
          flash[:ko] = 1
          
        end     
        flash[:cycle_id] = cycle.id
      end
    else
      flash[:ko] = 99
    end
	redirect_to controller: 'releases', action: 'index'
  end


  
end
