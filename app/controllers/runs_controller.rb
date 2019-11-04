class RunsController < ApplicationController
  before_action :require_login

  
  def index
		kop = (params[:kop] != nil ? params[:kop].to_s : flash[:kop]).to_s
		@popup = (params[:popup] != nil ? params[:popup].to_s : flash[:popup]).to_s
		@test_id = (params[:test_id] != nil ? params[:test_id] : flash[:test_id]).to_s
		@suite_id = (params[:suite_id] != nil ? params[:suite_id] : flash[:suite_id]).to_s
		@campain_id = (params[:campain_id] != nil ? params[:campain_id] : flash[:campain_id]).to_s
		@ftest_id = (params[:ftest] != nil ? params[:ftest] : flash[:ftest]).to_s
		@fsuite_id = (params[:fsuite] != nil ? params[:fsuite] : flash[:fsuite]).to_s
		@fcampain_id = (params[:fcampain] != nil ? params[:fcampain] : flash[:fcampain]).to_s
		
		if @ftest_id != "" or @fsuite_id != "" or @fcampain_id != "" then @filtre = true else @filtre = false end 
		if @ftest_id == "" then @ftest_id = @test_id end
		if @fsuite_id == "" then @fsuite_id = @suite_id end
		if @fcampain_id == "" then @fcampain_id = @campain_id else @campain_id =  @fcampain_id end
		 
		filtre_test = ""
		filtre_suite = ""
		filtre_campain = ""
		join_result_step = "LEFT OUTER "
		join_campain = "LEFT OUTER "
		
		if @ftest_id != ""
		  join_result_step = "LEFT OUTER "
		  filtre_test = " and runs.test_id = #{@ftest_id}"
		  test = Test.where(:id => @ftest_id).first
		  if test != nil
			@testname = test.name
			@test_id = test.id
		  end
		end
		if @fsuite_id != ""
		  join_result_step = "INNER "
		  filtre_suite = " and runs.suite_id = #{@fsuite_id}"
		  suite = Sheet.where(:domaine_id => @domaine, :id => @fsuite_id).first
		  if suite != nil
			@suitename = suite.name
			@suite_id = suite.id
		  end
		end
		if @fcampain_id != ""
		  join_campain = "INNER "
		  filtre_campain = " and runs.campain_id = #{@fcampain_id}"
		  campain = Campain.where(:id => @fcampain_id).first
		  if campain != nil
			@campainname = campain.name
			@campain_id = campain.id
		  end
		  @conceptionsheets = Sheet.select("distinct sheets.id, sheets.name").where("sheets.id in (select distinct conceptionsheets.id from campains
		  INNER JOIN campain_test_suites on campain_test_suites.domaine_id = campains.domaine_id and campain_test_suites.campain_id = campains.id
		  INNER JOIN sheets as suites on campain_test_suites.domaine_id = suites.domaine_id and campain_test_suites.sheet_id = suites.id
		  INNER JOIN nodes as suitetests on suitetests.domaine_id = suites.domaine_id and suitetests.sheet_id = suites.id
		  INNER JOIN test_steps on suitetests.domaine_id = test_steps.domaine_id and test_steps.test_id = suitetests.obj_id
		  INNER JOIN sheets as conceptionsheets on conceptionsheets.domaine_id = test_steps.domaine_id and conceptionsheets.id = test_steps.sheet_id and (conceptionsheets.private = 0 or conceptionsheets.owner_user_id = #{@my_user_id}) 
		  where campains.id = #{@fcampain_id}) or
		  sheets.id in (select distinct conceptionsheets.id from campains
		  INNER JOIN campain_test_suites on campain_test_suites.domaine_id = campains.domaine_id and campain_test_suites.campain_id = campains.id
		  INNER JOIN sheets as suites on campain_test_suites.domaine_id = suites.domaine_id and campain_test_suites.sheet_id = suites.id
		  INNER JOIN nodes as suitetests on suitetests.domaine_id = suites.domaine_id and suitetests.sheet_id = suites.id
		  INNER JOIN test_steps on suitetests.domaine_id = test_steps.domaine_id and test_steps.test_id = suitetests.obj_id
		  INNER JOIN test_steps as atdd_steps on atdd_steps.domaine_id = test_steps.domaine_id and atdd_steps.test_id = test_steps.atdd_test_id
		  INNER JOIN sheets as conceptionsheets on conceptionsheets.domaine_id = atdd_steps.domaine_id and conceptionsheets.id = atdd_steps.sheet_id and (conceptionsheets.private = 0 or conceptionsheets.owner_user_id = #{@my_user_id}) 
		  where campains.id = #{@fcampain_id})").order("sheets.name")
	  
		end
		condition_projet_version = ""
		if @popup != "true"
		  condition_projet_version = " and runs.version_id = #{@selectedversion} and runs.project_id = #{@selectedproject} "
		end
		@runs = Run.select("distinct runs.id as run_id, versions.name as version_name, 
		runs.name, users.id as run_user, 
		runs.private, username, hostrequest, 
		runs.status, runs.updated_at, 
		runs.nbprocfail as nbfail,
		runs.nbtest,
		runs.nbtestpass,
		runs.nbtestfail,
		runs.campain_id, runs.campain_test_suite_id, runs.suite_id, runs.test_id, runs.nb_screenshots_diffs, runs.created_at")
		.joins("INNER JOIN versions on versions.id = runs.version_id")
		.joins("INNER JOIN users on users.domaine_id = runs.domaine_id and runs.user_id = users.id")
		.where("runs.domaine_id = #{@domaine} #{filtre_campain} #{filtre_suite} #{filtre_test} #{condition_projet_version} and (runs.user_id = #{@my_user_id} or runs.private = 0) 
	and runs.run_father_id is null")
		.all.order("run_id DESC")
	
   	    @message, @OK = Commun.set_message(kop)

  end  
    

  def delete
    @popup = params[:popup].to_s
    test_id = params[:test_id].to_s
    suite_id = params[:suite_id].to_s
    campain_id = params[:campain_id].to_s
    run_id = params[:run_id]
    if run_id != nil
      run = Run.where(:domaine_id => @domaine, :id => run_id).first
      if run != nil
        public = 0
        if  run.campain_id != nil
          campain = Campain.where(:id => run.campain_id).first
          if campain != nil and campain.private == 0
            public = 1
          end
        end
        
        if  (run.user_id == @my_user_id) or (@can_manage_public_campain == 1 and public == 1) then
          run = Run.where(:id => run_id).first
          if run != nil then 
		    screenshots = RunScreenshot.where(:domaine_id => @domaine, :run_id => run.id).all
			screenshots.each do |screenshot|
				begin
					File.delete("./public/screenshots/#{screenshot.pngname}")
				rescue
				end
			end
			run.destroy 
		  end
        else
          kop = 9
        end
      end
    end
    redirect_to controller: 'runs', action: 'index',  rd: 1, kop: kop, popup: @popup, test_id: test_id, suite_id: suite_id, campain_id: campain_id
  end

  def stop
    run_id = params[:run_id]
    if run_id != nil
      run = Run.where(:domaine_id => @domaine, :id => run_id).first
      run.status = 'ended'
	  if run.suite_id != nil
		nodes = Node.where(:domaine_id => @domaine, :sheet_id => run.suite_id).all
		if nodes != nil
			nodes.each do |node|
				runendednode = RunEndedNode.new(:domaine_id => @domaine, 
				:run_id => run.id, 
				:test_node_id_externe => node.id_externe)
				runendednode.save
			end
		end
	  end
	  run.save
	  Run.where(:domaine_id => @domaine, :run_father_id => run.id).update_all(:status => 'ended')
	  RunStepResult.where(:domaine_id => @domaine, :run_id => run.id, :result => "start").update_all(:result => 'stop')
	  RunAuthentication.where(:run_id => run.id).delete_all
      RunStoreDatum.where(:domaine_id => @domaine, :run_id => run.id).delete_all
    end
	
    render json: '', status: '200'
  end

  def unlock
    run_id = params[:run_id]
    if run_id != nil
      run = Run.where(:domaine_id => @domaine, :id => run_id).first
      run.status = 'startable'
	  run.save
	end
    render json: '', status: '200'
  end  
end
