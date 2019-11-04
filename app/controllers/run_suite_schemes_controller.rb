class RunSuiteSchemesController < ApplicationController
  before_action :require_login

  def index
    begin
      @popup = params[:popup].to_s
      @run_id = params[:run_id].to_s
      @nodes = nil
      @links = nil
      @run = Run.select("status").where(:id => @run_id).first
      runsuitescheme = RunSuiteScheme.where(:domaine_id => @domaine, :run_id => @run_id).first
      if runsuitescheme != nil
		    @sheet = Sheet.where(:domaine_id => @domaine, :id => runsuitescheme.suite_id).first
        @nodes = runsuitescheme.jsonnode
        @links = runsuitescheme.jsonlink
        if @nodes.include? "$nbprocfail"
          nodenbprocpassfails = RunStepResult
		  .select("test_node_id_externe,
		  sum(case when result='PASS' then 1 else 0 end) as nbpass,
		  sum(case when result='FAIL' then 1 else 0 end) as nbfail")
          .where("run_step_results.domaine_id = #{@domaine}
		  and run_step_results.run_id = #{@run_id}
		  and run_step_results.suite_id = #{runsuitescheme.suite_id}
		  and steplevel='procedure'").group("test_node_id_externe").all
          nodenbprocpassfails.each do |nodenbprocpassfail|
            @nodes = @nodes.gsub("$nbprocpass#{nodenbprocpassfail.test_node_id_externe}$", "#{nodenbprocpassfail.nbpass}").gsub("$nbprocfail#{nodenbprocpassfail.test_node_id_externe}$", "#{nodenbprocpassfail.nbfail}")
          end
        end

        if @nodes.include? "$nbprocfail" or @nodes.include? "$nbprocpass"
          tnode = @nodes.to_s.split("$")
          for i in 0..tnode.length-1
            if tnode[i].start_with? "nbprocfail" or tnode[i].start_with? "nbprocpass"
              tnode[i] = "0"
            end
          end
        end
		@startedtests = RunStepResult
		  .select("test_node_id_externe as id")
          .where("run_step_results.domaine_id = #{@domaine}
		  and run_step_results.run_id = #{@run_id}
		  and run_step_results.suite_id = #{runsuitescheme.suite_id}
		  and steplevel='test' and result='start'").all
      end
      @nodes = tnode.join('')
    end
  rescue Exception => e
	Rails.logger.error e.message
    redirect_to controller: 'runs', action: 'index'
  end
end
