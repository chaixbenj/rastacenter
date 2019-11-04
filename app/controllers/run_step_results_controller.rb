class RunStepResultsController < ApplicationController
  before_action :require_login

  
  def index
    run_id = params[:run_id].to_s
    test_node_id_externe = params[:test_node_id_externe].to_s
    @popup = params[:popup].to_s
	joinphoto = "LEFT OUTER JOIN"
	joinphotodiff = "LEFT OUTER JOIN"
	@photo = params[:photo]
	if params[:photo].to_s != "" then joinphoto = "INNER JOIN" end
	if params[:photo].to_s == "diff" then joinphotodiff = "INNER JOIN" end
	
    if run_id != ""
      @run  = Run.where(:id => run_id).first
      if @run != nil
        user = User.where(:id => @run.user_id, :domaine_id => @domaine).first
        if user != nil
          @username = user.username
        end
        filter_node = ""
        if test_node_id_externe != ""
          filter_node = " and test_node_id_externe=#{test_node_id_externe}"
        end
        @results = RunStepResult.select("run_step_results.*, run_screenshots_last.pngname as lastpngname, run_screenshots_diff.pngname as diffpngname, run_screenshots_diff.has_diff as has_diff, run_screenshots_diff.prct_diff as prct_diff, ref_screenshots.pngname as refpngname, run_screenshots_last.id as id_photo_last, run_screenshots_diff.id as id_photo_diff, ref_screenshots.id as id_photo_ref, funcandscreens.id as funcscreen_id")
        .joins("#{joinphoto} run_screenshots as  run_screenshots_last
on run_screenshots_last.domaine_id = run_step_results.domaine_id 
and run_screenshots_last.run_id = run_step_results.run_id 
and run_screenshots_last.guid = run_step_results.detail
and run_screenshots_last.type_screenshot = 'last'")
		.joins("#{joinphotodiff} run_screenshots  as  run_screenshots_diff
on run_screenshots_diff.domaine_id = run_step_results.domaine_id 
and run_screenshots_diff.run_id = run_step_results.run_id 
and run_screenshots_diff.guid = run_screenshots_last.guid
and run_screenshots_diff.type_screenshot = 'diff' and run_screenshots_diff.has_diff = 1")
		.joins("#{joinphotodiff} ref_screenshots  
on ref_screenshots.domaine_id = run_step_results.domaine_id 
and ref_screenshots.name = run_screenshots_last.name 
and ref_screenshots.location = run_screenshots_last.location
and ref_screenshots.configstring = run_screenshots_last.configstring")
		.joins("LEFT OUTER JOIN procedures  
on procedures.domaine_id = run_step_results.domaine_id 
and procedures.id = run_step_results.proc_id")
		.joins("LEFT OUTER JOIN funcandscreens  
on funcandscreens.domaine_id = run_step_results.domaine_id 
and funcandscreens.id = procedures.funcandscreen_id")
        .where("run_step_results.domaine_id = #{@domaine} and run_step_results.run_id = #{run_id} #{filter_node}").all.order("suite_sequence, test_node_id_externe, atdd_sequence, proc_sequence, run_step_results.id")

@bugs = Fiche.select("distinct run_step_results.id as step_id, fiches.id as bug_id, fiches.name as bug_name")
        .joins("INNER JOIN run_step_results 
on fiches.domaine_id = run_step_results.domaine_id 
and fiches.test_id = run_step_results.test_id 
and fiches.proc_id = run_step_results.proc_id
and fiches.action_id = run_step_results.action_id")
		.joins("INNER JOIN type_fiches on type_fiches.id = fiches.type_fiche_id")
		.joins("INNER JOIN sheets on sheets.id = type_fiches.sheet_id")
		.joins("INNER JOIN nodes on nodes.domaine_id = sheets.domaine_id and nodes.sheet_id = sheets.id and nodes.obj_id = fiches.status_id and nodes.obj_type != 'endpoint'")
        .where("run_step_results.domaine_id = #{@domaine} and run_step_results.run_id = #{run_id} #{filter_node}").all
        .order("run_step_results.id, fiches.id DESC")

      end
    end
  end  
    

  def force
    step_id = params[:step_id]
    passorfail = params[:passorfail]
    run_step_result = RunStepResult.where(:id => step_id).first
    result = 'no change'
    if run_step_result != nil
      case passorfail
      when 'PASS'
        if run_step_result.result.start_with? 'FAIL'
          if run_step_result.initial_result == nil then run_step_result.initial_result = run_step_result.result end
          run_step_result.result = 'PASS'
          run_step_result.histo = run_step_result.histo.to_s +  "\nforce PASS (#{@username} #{Time.now.localtime.to_s[0..-7]})"
          run_step_result.save
          result = "#{step_id};#93FA5F;<span class='textStyle'>PASS forced (init #{run_step_result.initial_result})</span>||"
          if run_step_result.steplevel == 'action'
            proc_step_father = RunStepResult.where(:domaine_id => run_step_result.domaine_id, :run_id => run_step_result.run_id, :suite_id => run_step_result.suite_id, :suite_sequence => run_step_result.suite_sequence, :test_id => run_step_result.test_id, :test_node_id_externe => run_step_result.test_node_id_externe, :proc_id => run_step_result.proc_id, :proc_sequence => run_step_result.proc_sequence, :steplevel => 'procedure').first
            hasfail = RunStepResult.where("domaine_id = #{run_step_result.domaine_id} and run_id = #{run_step_result.run_id} and suite_id = #{run_step_result.suite_id} and suite_sequence = #{run_step_result.suite_sequence} and test_id = #{run_step_result.test_id} and test_node_id_externe = #{run_step_result.test_node_id_externe} and proc_id = #{run_step_result.proc_id} and proc_sequence = #{run_step_result.proc_sequence} and steplevel = 'action' and result like 'FAIL%'").first
            if proc_step_father != nil and hasfail == nil
              if proc_step_father.initial_result == nil then proc_step_father.initial_result = proc_step_father.result end
              proc_step_father.result = 'PASS'
              proc_step_father.histo = proc_step_father.histo.to_s +  "\nforce PASS (#{@username} #{Time.now.localtime.to_s[0..-7]})"
              proc_step_father.save
              result += "#{proc_step_father.id};#93FA5F;<span class='textStyle'>PASS forced (init #{proc_step_father.initial_result})</span>||"
            end
          end
          if run_step_result.steplevel == 'action' or run_step_result.steplevel == 'procedure'
            test_step_father = RunStepResult.where(:domaine_id => run_step_result.domaine_id, :run_id => run_step_result.run_id, :suite_id => run_step_result.suite_id, :suite_sequence => run_step_result.suite_sequence, :test_id => run_step_result.test_id, :test_node_id_externe => run_step_result.test_node_id_externe, :steplevel => 'test').first
            hasfail = RunStepResult.where("domaine_id = #{run_step_result.domaine_id} and run_id = #{run_step_result.run_id} and suite_id = #{run_step_result.suite_id} and suite_sequence = #{run_step_result.suite_sequence} and test_id = #{run_step_result.test_id} and test_node_id_externe = #{run_step_result.test_node_id_externe} and steplevel = 'procedure' and result like 'FAIL%'").first
            if test_step_father != nil and hasfail == nil
              if test_step_father.initial_result == nil then test_step_father.initial_result = test_step_father.result end
              test_step_father.result = 'PASS'
              test_step_father.histo = test_step_father.histo.to_s +  "\nforce PASS (#{@username} #{Time.now.localtime.to_s[0..-7]})"
              test_step_father.save
              result += "#{test_step_father.id};#93FA5F;<span class='textStyle'>PASS forced (init #{test_step_father.initial_result})</span>||"
            end
          end
          if run_step_result.steplevel == 'action' or run_step_result.steplevel == 'procedure'  or run_step_result.steplevel == 'test'
            suite_step_father = RunStepResult.where(:domaine_id => run_step_result.domaine_id, :run_id => run_step_result.run_id, :suite_id => run_step_result.suite_id, :suite_sequence => run_step_result.suite_sequence, :steplevel => 'suite').first
            hasfail = RunStepResult.where("domaine_id = #{run_step_result.domaine_id} and run_id = #{run_step_result.run_id} and suite_id = #{run_step_result.suite_id} and suite_sequence = #{run_step_result.suite_sequence} and steplevel = 'test' and result like 'FAIL%'").first
            if suite_step_father != nil and hasfail == nil
              if suite_step_father.initial_result == nil then suite_step_father.initial_result = suite_step_father.result end
              suite_step_father.result = 'PASS'
              suite_step_father.histo = suite_step_father.histo.to_s +  "\nforce PASS (#{@username} #{Time.now.localtime.to_s[0..-7]})"
              suite_step_father.save
              result += "#{suite_step_father.id};#93FA5F;<span class='textStyle'>PASS forced (init #{suite_step_father.initial_result})</span>||"
            end
          end
          if run_step_result.steplevel == 'test'
            run_step_results = RunStepResult.where(:domaine_id => run_step_result.domaine_id, :run_id => run_step_result.run_id, :suite_id => run_step_result.suite_id, :suite_sequence => run_step_result.suite_sequence, :test_id => run_step_result.test_id, :test_node_id_externe => run_step_result.test_node_id_externe).all
            run_step_results.each do |sub_result|
              if sub_result.result.start_with? 'FAIL'
                if sub_result.initial_result == nil then sub_result.initial_result = sub_result.result end
                sub_result.result = 'PASS'
                sub_result.histo = sub_result.histo.to_s +  "\nforce PASS (#{@username} #{Time.now.localtime.to_s[0..-7]})"
                sub_result.save
                result += "#{sub_result.id};#93FA5F;<span class='textStyle'>PASS forced (init #{sub_result.initial_result})</span>||"
              end
            end
          end
          if run_step_result.steplevel == 'procedure'
            run_step_results = RunStepResult.where(:domaine_id => run_step_result.domaine_id, :run_id => run_step_result.run_id, :suite_id => run_step_result.suite_id, :suite_sequence => run_step_result.suite_sequence, :test_id => run_step_result.test_id, :test_node_id_externe => run_step_result.test_node_id_externe, :proc_id => run_step_result.proc_id, :proc_sequence => run_step_result.proc_sequence).all
            run_step_results.each do |sub_result|
              if sub_result.result.start_with? 'FAIL'
                if sub_result.initial_result == nil then sub_result.initial_result = sub_result.result end
                sub_result.result = 'PASS'
                sub_result.histo = sub_result.histo.to_s +  "\nforce PASS (#{@username} #{Time.now.localtime.to_s[0..-7]})"
                sub_result.save
                result += "#{sub_result.id};#93FA5F;<span class='textStyle'>PASS forced (init #{sub_result.initial_result})</span>||"
              end
            end
          end
        end
        
        
      when 'FAIL'
        if run_step_result.result.start_with? 'PASS'
          if run_step_result.initial_result == nil then run_step_result.initial_result = run_step_result.result end
          run_step_result.result = 'FAIL'
          run_step_result.histo = run_step_result.histo.to_s +  "\nforce FAIL (#{@username} #{Time.now.localtime.to_s[0..-7]})"
          run_step_result.save
          result = "#{step_id};#F96868;<span class='textStyle'>FAIL forced (init #{run_step_result.initial_result})</span>||"
          
          
          if run_step_result.steplevel == 'action'
            proc_step_father = RunStepResult.where(:domaine_id => run_step_result.domaine_id, :run_id => run_step_result.run_id, :suite_id => run_step_result.suite_id, :suite_sequence => run_step_result.suite_sequence, :test_id => run_step_result.test_id, :test_node_id_externe => run_step_result.test_node_id_externe, :proc_id => run_step_result.proc_id, :proc_sequence => run_step_result.proc_sequence, :steplevel => 'procedure').first
            if proc_step_father != nil and proc_step_father.result.start_with? "PASS"
              if proc_step_father.initial_result == nil then proc_step_father.initial_result = proc_step_father.result end
              proc_step_father.result = 'FAIL'
              proc_step_father.histo = proc_step_father.histo.to_s +  "\nforce FAIL (#{@username} #{Time.now.localtime.to_s[0..-7]})"
              proc_step_father.save
              result += "#{proc_step_father.id};#F96868;<span class='textStyle'>FAIL forced (init #{proc_step_father.initial_result})</span>||"
            end
          end
          if run_step_result.steplevel == 'action' or run_step_result.steplevel == 'procedure'
            test_step_father = RunStepResult.where(:domaine_id => run_step_result.domaine_id, :run_id => run_step_result.run_id, :suite_id => run_step_result.suite_id, :suite_sequence => run_step_result.suite_sequence, :test_id => run_step_result.test_id, :test_node_id_externe => run_step_result.test_node_id_externe, :steplevel => 'test').first
            if test_step_father != nil and test_step_father.result.start_with? "PASS"
              if test_step_father.initial_result == nil then test_step_father.initial_result = test_step_father.result end
              test_step_father.result = 'FAIL'
              test_step_father.histo = test_step_father.histo.to_s +  "\nforce FAIL (#{@username} #{Time.now.localtime.to_s[0..-7]})"
              test_step_father.save
              result += "#{test_step_father.id};#F96868;<span class='textStyle'>FAIL forced (init #{test_step_father.initial_result})</span>||"
            end
          end
          if run_step_result.steplevel == 'action' or run_step_result.steplevel == 'procedure'  or run_step_result.steplevel == 'test'
            suite_step_father = RunStepResult.where(:domaine_id => run_step_result.domaine_id, :run_id => run_step_result.run_id, :suite_id => run_step_result.suite_id, :suite_sequence => run_step_result.suite_sequence, :steplevel => 'suite').first
            if suite_step_father != nil and suite_step_father.result.start_with? "PASS"
              if suite_step_father.initial_result == nil then suite_step_father.initial_result = suite_step_father.result end
              suite_step_father.result = 'FAIL'
              suite_step_father.histo = suite_step_father.histo.to_s +  "\nforce FAIL (#{@username} #{Time.now.localtime.to_s[0..-7]})"
              suite_step_father.save
              result += "#{suite_step_father.id};#F96868;<span class='textStyle'>FAIL forced (init #{suite_step_father.initial_result})</span>||"
            end
          end
          
          
          
          if run_step_result.steplevel == 'test'
            run_step_results = RunStepResult.where(:domaine_id => run_step_result.domaine_id, :run_id => run_step_result.run_id, :suite_id => run_step_result.suite_id, :suite_sequence => run_step_result.suite_sequence, :test_id => run_step_result.test_id, :test_node_id_externe => run_step_result.test_node_id_externe).all
            run_step_results.each do |sub_result|
              if sub_result.result.start_with? 'PASS'
                if sub_result.initial_result == nil then sub_result.initial_result = sub_result.result end
                sub_result.result = 'FAIL'
                sub_result.histo = sub_result.histo.to_s +  "\nforce FAIL (#{@username} #{Time.now.localtime.to_s[0..-7]})"
                sub_result.save
                result += "#{sub_result.id};#F96868;<span class='textStyle'>FAIL forced (init #{run_step_result.initial_result})</span></span>||"
              end
            end
          end
          if run_step_result.steplevel == 'procedure'
            run_step_results = RunStepResult.where(:domaine_id => run_step_result.domaine_id, :run_id => run_step_result.run_id, :suite_id => run_step_result.suite_id, :suite_sequence => run_step_result.suite_sequence, :test_id => run_step_result.test_id, :test_node_id_externe => run_step_result.test_node_id_externe, :proc_id => run_step_result.proc_id, :proc_sequence => run_step_result.proc_sequence).all
            run_step_results.each do |sub_result|
              if sub_result.result.start_with? 'PASS'
                if sub_result.initial_result == nil then sub_result.initial_result = sub_result.result end
                sub_result.result = 'FAIL'
                sub_result.histo = sub_result.histo.to_s +  "\nforce FAIL (#{@username} #{Time.now.localtime.to_s[0..-7]})"
                sub_result.save
                result += "#{sub_result.id};#F96868;<span class='textStyle'>FAIL forced (init #{run_step_result.initial_result})</span></span>||"
              end
            end
          end
        end
      end
    end
    render html: result.html_safe
  end 

  
  def comment
    @step_id = params[:step_id]
    @popup = params[:popup]
    comment = params[:comment]
    step = RunStepResult.where(:id => @step_id).first
    if step != nil
      if comment != nil and comment != step.comment
        comment += "\n(#{@username} #{Time.now.localtime.to_s[0..-7]})"
        step.comment = comment
        step.save
      end
      @comment = step.comment
      if step.histo != nil
      @histo = step.histo.gsub("\n","<br>").html_safe
      end
    end
  end
  
  def setrefscreenshot
	ref_id = params[:ref_id].to_s
	last_id = params[:last_id].to_s
	diff_id = params[:diff_id].to_s
	
	if last_id != ""
		last_screenshot = RunScreenshot.where(:id => last_id).first
		if diff_id != ""
			diff_screenshot = RunScreenshot.where(:id => diff_id).first
			if diff_screenshot != nil then 
				File.delete("./public/screenshots/#{diff_screenshot.pngname}")
				diff_screenshot.destroy 
			end
		end
		if last_screenshot != nil
			ref_screenshot = RefScreenshot.where(:id => ref_id).first
			if ref_screenshot != nil
				if File.exists?("./public/screenshots/#{ref_screenshot.pngname}")
					File.delete("./public/screenshots/#{ref_screenshot.pngname}")
				end
				png_data = File.open("./public/screenshots/#{last_screenshot.pngname}", "rb").read
				newfile = File.open("./public/screenshots/ref_#{last_screenshot.pngname}", "wb")
				scaled_bytes = png_data #Base64.decode64(screenshotdata)
				newfile.puts scaled_bytes
				newfile.close
				ref_screenshot.pngname = "ref_" + last_screenshot.pngname
				ref_screenshot.save
			end
			run = Run.where(:id => last_screenshot.run_id).first
			if run != nil
				run.nb_screenshots_diffs = run.nb_screenshots_diffs.to_s.to_i - 1
				run.save
			end
		end
	end
	render json: '', status: '200'
  end
  
end
