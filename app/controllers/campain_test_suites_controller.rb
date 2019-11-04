class CampainTestSuitesController < ApplicationController
  before_action :require_login




  def addnew
    campain_id = params[:campain_id].to_s
    lockcampain(campain_id)
    suite_id = params[:sheet_id].to_s
    suite = Sheet.where(:id => suite_id).first
    current_sheet = Sheet.where(:id => suite.current_id).first
    if current_sheet != nil
      current_suite_id = current_sheet.id
    else
      Sheet.where(:domaine_id => @domaine, :current_id => suite.current_id).update_all(:current_id => suite.id)
      current_suite_id = suite.id
    end
  
    campain = Campain.where(:id => campain_id).first
    
    newStep = nil
    if campain != nil and suite != nil 
      recordsequence = CampainTestSuite.select("max(sequence) as valeur")
      .where(:domaine_id => @domaine, :campain_id => campain_id).first
      if recordsequence == nil or recordsequence.valeur == nil
        sequence = 1
      else
        sequence = recordsequence.valeur + 1
      end
      newStep = CampainTestSuite.new
      newStep.domaine_id = @domaine
      newStep.campain_id = campain_id
      newStep.sequence = sequence
      newStep.sheet_id = current_suite_id
      newStep.save
    end
	
	
    if newStep != nil
      rep = "<div name=\"divstep\"  id='divstepseq#{newStep.sequence}' draggable=\"true\" ondragstart=\"dragStarted(event, this.id);\" ondragover=\"draggingOver(event, this.id);\" ondrop=\"droppedsuite(event, this.id);\">"
      rep += "<div id=\"divstepid#{newStep.id}\" class=\"ligthline\" style=\"padding:5px 5px 5px 5px;\"><div >"
      rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{newStep.sequence});' id='#{newStep.sequence}' value='#{newStep.id}'/><span>&nbsp;#{suite.name}</span>"
      rep += "<button class='btndel' style='float: right;' onclick='deletecampainstep(#{newStep.id})'></button>"

      rep += "<button id='btnconf#{newStep.id}' class='btnvariable' title=\"#{t('ecr_campain.forcer_conf_sur_suite')}\" style='float: right;' onclick=\"document.getElementById('contentpopup').innerHTML='<object id=\\'objpopup\\' width=\\'99%\\' data=\\'../campain_test_suite_forced_configs/index?popup=true&step_id=#{newStep.id}\\'></object>';window.location.href='#popup';document.getElementById('popup').style.display='block';document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);\"></button>"
      rep += "<button class='btndiagsmall' style='float: right;' title=\"#{t('ecr_sheet.modifier_la_suite')}\" onclick=\"document.getElementById('ojecttypepopuped').value='test_suite';document.getElementById('ojectidpopuped').value=#{newStep.sheet_id};document.getElementById('contentpopup').innerHTML='<object id=\\'objpopup\\' width=\\'99%\\' data=\\'../sheets/edit?popup=true&write="
      if (@can_manage_public_test_suite == 1 and suite.private == 0) or suite.owner_user_id == @my_user_id 
        rep += "1"
      else
        rep += "0"
      end
      rep += "&sheet_id=#{newStep.sheet_id}&load=1&sheettype=test_suite\\'></object>';window.location.href='#popup';document.getElementById('popup').style.display='block';document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);\"></button>  "
      rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastecampainstep(\"after\", #{newStep.id})'></button>"
      rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastecampainstep(\"before\", #{newStep.id})'></button>"

      rep += "</div><div style=\"display: block\">"
       
      rep += "</div></div></div>" 
      render html: rep.html_safe  
    else
      render html: 'KO'  
    end
  
  end


  def reorder
    campain_id = params[:campain_id].to_s
    lockcampain(campain_id)
    istart = params[:istart].to_s.to_i
    idest = params[:idest].to_s.to_i
    stepstart = CampainTestSuite.where(:domaine_id => @domaine, :campain_id => campain_id, :sequence => istart).first
  
    if istart < idest
      CampainTestSuite
      .where("domaine_id = #{@domaine} and campain_id = #{campain_id} and sequence <= #{idest} and sequence > #{istart}")
      .update_all("sequence = sequence - 1")
      if stepstart != nil
        stepstart.sequence = idest
        stepstart.save
      end
    end

    if istart > idest
      CampainTestSuite
      .where("campain_id = #{campain_id} and sequence >= #{idest} and sequence < #{istart}")
      .update_all("sequence = sequence + 1")
      if stepstart != nil
        stepstart.sequence = idest
        stepstart.save
      end
    end  
    render html: "reorder;#{istart};#{idest}"
  
  end



  def delete
    lockcampain(params[:campain_id])
    step_id = params[:step_id]
    step = CampainTestSuite.where(:id => step_id).first
    if step != nil
      CampainTestSuite
      .where("domaine_id = #{@domaine} and campain_id = #{step.campain_id} and sequence > #{step.sequence}")
      .update_all("sequence = sequence - 1")
      step.destroy
    end
    render html: "delete;#{step_id}"
  end


  def paste
    lockcampain(params[:campain_id])
    afterbefore = params[:paste_after_before].to_s
    elem_dest = params[:paste_element_dest].to_s
    step_to_paste = params[:testsuite_to_paste].to_s.split('||')
    copycut = step_to_paste[0].gsub('|', '')
    step_to_paste = params[:testsuite_to_paste].gsub('copy|','').gsub('cut|','').to_s.split('||')
    mycampain = Campain.where(:id => params[:campain_id]).first
    if mycampain != nil
      nbsteptopaste = step_to_paste.length
      if elem_dest == ""
        istart = 1
      else
        destinationsequence = CampainTestSuite.where(:id => elem_dest).first.sequence
        istart = destinationsequence
        if afterbefore == 'after' #on fait la place dans la destination
          CampainTestSuite
          .where("domaine_id = #{@domaine} and campain_id = #{mycampain.id} and sequence > #{destinationsequence}")
          .update_all("sequence = sequence + #{nbsteptopaste}")
          istart += 1
        else
          CampainTestSuite
          .where("domaine_id = #{@domaine} and campain_id = #{mycampain.id} and sequence >= #{destinationsequence}")
          .update_all("sequence = sequence + #{nbsteptopaste}")
        end
      end
      if copycut == 'copy' #on copie
        step_to_paste.each do |step_id|
          step_id = step_id.gsub('|', '')
          initcampainstep = CampainTestSuite.where(:id => step_id).first
          newstep = initcampainstep.dup
          newstep.campain_id = mycampain.id
          newstep.sequence = istart
          newstep.save
          istart += 1
        end
      else
        if copycut == 'cut' #ou on colle
          oldcampain_id = nil 
          step_to_paste.each do |step_id|
            step_id = step_id.gsub('|', '')
            if oldcampain_id == nil
              oldcampain = CampainTestSuite.where(:id => step_id).first
              if oldcampain != nil
                oldcampain_id = oldcampain.campain_id
              end
            end
            CampainTestSuite.where(:id => step_id).update(:campain_id => mycampain.id, :sequence => istart)
            istart += 1
          end
          recalculsequence(oldcampain_id)
        end
      end 
    end
    flash[:campain_id] = params[:campain_id]
    flash[:write] = params[:write]
    flash[:back_to_id] = params[:back_to_id]
    flash[:popup] = params[:popup]
    redirect_to controller: 'campains', action: 'edit'
  end


  def lockcampain(campain_id)
    Lockobject.where("domaine_id = #{@domaine} and obj_id = #{campain_id} and obj_type = 'campain'").delete_all
    newlock = Lockobject.new
    newlock.domaine_id = @domaine
    newlock.obj_id = campain_id
    newlock.obj_type = 'campain'
    newlock.user_id = @my_user_id
    newlock.save
    cookies[:objectlocked] = '1'
  end


  def recalculsequence(campain_id)
    if campain_id != nil
      campainsteps = CampainTestSuite
      .where(:domaine_id => @domaine, :campain_id => campain_id).order(:sequence).all
      i = 0
      campainsteps.each do |campainstep|
        i+=1
        campainstep.sequence = i
        campainstep.save
      end
    end
  end

end
