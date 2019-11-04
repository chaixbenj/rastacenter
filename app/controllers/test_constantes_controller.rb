
class TestConstantesController < ApplicationController
  before_action :require_login
  

 
  def index
    @message=params[:message]
    if params[:ok].to_s == 'ko'
      @OK = false
    else
      @OK = true
    end
    name = params["name"].to_s
    description = params["description"].to_s
    filter = ""
    if name != ""
      filter += " and name like '%#{name}%'"
    end
    if description != ""
      filter += " and description like '%#{description}%'"
    end
     
    @testconstantes = TestConstante.where("domaine_id = #{@domaine} and project_id = #{@selectedproject} #{filter}").all
  end  
  
  def create
    @message=nil
    name = params["name"].to_s
    description = params["description"].to_s
	value = params["value"].to_s
	
	nom_variable_existant = false
    stringvariable = Commun.get_variables_string
    if stringvariable.index(name + "$") != nil or
         name.start_with? "$domelement" or
         EnvironnementVariable.where("domaine_id = #{@domaine} and environnement_id is null and name = '#{name}'").first != nil  or
         ConfigurationVariable.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil  or 
		 DataSetVariable.where(:domaine_id => @domaine, :data_set_id => nil, :init_variable_id => nil, :name => name).first != nil  or
		 TestConstante.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil then
         nom_variable_existant = true
    end
	
    if nom_variable_existant == false
      @testconstante = TestConstante.new
      @testconstante.name = name
      @testconstante.description = description
	  @testconstante.value = value
      @testconstante.domaine_id = @domaine
	  @testconstante.project_id = @selectedproject
	  @testconstante.is_numeric = 0
	  @testconstante.is_boolean = 0
      @testconstante.save
    else
      @message = (I18n.t "message.nom_existant").gsub("{1}", name)
    end
    @testconstantes = TestConstante.where(:domaine_id => @domaine, :project_id => @selectedproject).all
  
    respond_to do |format|
      if @testconstante !=nil 
        format.html { redirect_to @testconstante, notice: 'TestConstante was successfully created.' }
        format.js   {}
        format.json { render json: @testconstante, status: :created, location: @testconstante }
      else
        format.html { redirect_to  controller: 'test_constantes', action: 'index'  , message: @message, ok: 'ko' }
        format.json { render json: @testconstante.errors, status: :unprocessable_entity }
      end
    end

  end


  def destroy
  	@message=nil
	@testconstante = TestConstante.where(:id => params[:id]).delete_all
    @testconstantes = TestConstante.where(:domaine_id => @domaine, :project_id => @selectedproject).all
  end
  
  def update
    @message=nil
    idelement = params["idelement"]
	name = params["name"]
    description = params["description"]
	value = params["value"]
    @majid = idelement
    
    @testconstante = TestConstante.where(:id => idelement).first
	
	nom_variable_existant = false
    stringvariable = Commun.get_variables_string
    if stringvariable.index(name + "$") != nil or
         name.start_with? "$domelement" or
         EnvironnementVariable.where("domaine_id = #{@domaine} and environnement_id is null and name = '#{name}'").first != nil  or
         ConfigurationVariable.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil  or 
		 DataSetVariable.where(:domaine_id => @domaine, :data_set_id => nil, :init_variable_id => nil, :name => name).first != nil  or
		 TestConstante.where("domaine_id = #{@domaine} and name = '#{name}' and id != #{idelement}").first != nil then
         nom_variable_existant = true
    end
	
    if @testconstante != nil and nom_variable_existant == false
      @testconstante.name = name
      @testconstante.description = description
	  @testconstante.value = value
	  if params[:isn] != nil 
		@testconstante.is_numeric = 1 
		@testconstante.value = value.to_f.to_s
	  else 
		@testconstante.is_numeric = 0 
	  end
	  if params[:isb] != nil  
	    @testconstante.is_boolean = 1 
		if value != "true" and value != "false"
			@testconstante.value = "true"
		end
	  else 
		@testconstante.is_boolean = 0 
	  end
   	  @testconstante.save
      @testconstantes = TestConstante.where(:domaine_id => @domaine, :project_id => @selectedproject).all
      @majid = @testconstante.id
      @message = I18n.t "message.maj_effectuee"
      @OK=true
     else
      @testconstantes = TestConstante.where(:domaine_id => @domaine, :project_id => @selectedproject).all
	  if nom_variable_existant == true
      @message = (I18n.t "message.nom_existant").gsub("{1}", name)
	  else
	  @message = I18n.t "message.operation_impossible"
	  end
      @OK=false
    end
  end  
  


  
end