require 'net/http'

class DomelementsController < ApplicationController
  before_action :require_login
  
  
  def index
    @message=nil
    @sheet_id = (params[:sheet_id] != nil ? params[:sheet_id] : flash[:sheet_id]).to_s
    @ext_node_id = (params[:ext_node_id] != nil ? params[:ext_node_id] : flash[:ext_node_id]).to_s
    @popup = (params[:popup] != nil ? params[:popup] : flash[:popup]).to_s
    ko = (params[:ko] != nil ? params[:ko] : flash[:ko]).to_s
    @elementslist = (params[:elementslist] != nil ? params[:elementslist] : flash[:elementslist]).to_s
    @funcscreen_id = (params[:funcscreen_id] != nil ? params[:funcscreen_id] : flash[:funcscreen_id])
    search_element = (params[:search_element] != nil ? params[:search_element] : flash[:search_element]).to_s
	
    @domelements = nil
	
    @findstrategies = Findstrategie.where(:domaine_id => @domaine).all
    
    if ko == "1"
      @message = I18n.t "message.elements_ci_dessous_non_inseres"
      @OK=false 
    end
	if search_element != "" then 
		search_element = search_element.split("|")
		filtre = " and ("
		s_or = ""
		search_element.each do |element|
			filtre += " #{s_or} name like '%#{element}%'"
			s_or = "or"
		end
		filtre += ")"
	else 
		filtre = "" 
	end
    if @sheet_id != ""
      sheet = Sheet.where(:id => @sheet_id).first
      if sheet != nil
        @version_id = sheet.version_id
        node = Node.where(:domaine_id => sheet.domaine_id, :sheet_id => @sheet_id, :id_externe => @ext_node_id).first
        if node != nil
          funcscreen = Funcandscreen.where(:id => node.obj_id).first
          if funcscreen != nil
            @funcscreen_id = funcscreen.id
            @domelements = Domelement.where("domaine_id = #{@domaine} and funcandscreen_id = #{@funcscreen_id} and version_id = #{@version_id} #{filtre}").order("domelements.name").all
          end
        end
      end
    else
      @version_id = @selectedversion
      @domelements = Domelement.where("domaine_id = #{@domaine} and funcandscreen_id = #{@funcscreen_id} and version_id = #{@version_id} #{filtre}").order("domelements.name").all
    end
   
  end
  
  
  def create
    @message=nil
    @funcandscreen_id = params["funcandscreen_id"]
    @version_id = params["version_id"]
    @popup = params[:popup].to_s  
    if params[:pasteadd] == "add"  
      name = params["name"]
      strategie = params["strategie"]
      path = params["path"]
      description = params["description"]
      @domelement = Domelement.new
      @domelement.domaine_id = @domaine
      @domelement.name = name
      @domelement.strategie = strategie
      @domelement.path = path
      @domelement.description = description
      @domelement.funcandscreen_id = @funcandscreen_id
      @domelement.version_id = @version_id
      @domelement.is_used = 0
      @domelement.save 	
      @domelement.current_id = @domelement.id
    else
      if params[:pasteadd] == "paste"  and cookies[:domelement_copy].to_s != ""
        domelement = Domelement.where(:id => cookies[:domelement_copy].to_i).first
        if domelement != nil
          @domelement = domelement.dup
          @domelement.domaine_id = @domaine
          @domelement.name += "_copy"
          @domelement.funcandscreen_id = @funcandscreen_id
          @domelement.version_id = @version_id     
          @domelement.is_used = 0
          @domelement.save 	
          @domelement.current_id = @domelement.id
          cookies.delete(:domelement_copy)
        end
      end
    end
    @findstrategies = Findstrategie.where(:domaine_id => @domaine).all
    respond_to do |format|
      if @domelement.save
        ComputerLastGet.where(:domaine_id => @domaine, :object_type => "FuncAndScreen#{@domelement.funcandscreen_id}", :version_id => @version_id, :get => 0).update_all(:get => 1)
        @domelements = Domelement.where(:domaine_id => @domaine, :funcandscreen_id => @funcandscreen_id, :version_id => @version_id).order("domelements.name").all
        format.html { redirect_to @domelement, notice: 'DOMelement was successfully created.' }
        format.js   {}
        format.json { render json: @domelement, status: :created, location: @domelement }
      else
        @domelements = Domelement.where(:domaine_id => @domaine, :funcandscreen_id => @funcandscreen_id, :version_id => @version_id).order("domelements.name").all
        format.html { render action: "index" }
        format.json { render json: @domelement.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    #!!!! TODO : ajouter un test avant de supprimer : l'element ne doit pas être appelé dans une proc
    @message=nil
    @popup = params[:popup].to_s
    @funcandscreen_id = params["funcandscreen_id"]
    @version_id = params["version_id"]
		@domelement = Domelement.where(:id => params[:id]).first
    if @domelement != nil
      @funcandscreen_id = @domelement.funcandscreen_id
      @version_id = @domelement.version_id
      @domelement.destroy
    end
    ComputerLastGet.where(:domaine_id => @domaine, :object_type => "FuncAndScreen#{@domelement.funcandscreen_id}", :version_id => @version_id, :get => 0).update_all(:get => 1)
    @domelements = Domelement.where(:domaine_id => @domaine, :funcandscreen_id => @funcandscreen_id, :version_id => @version_id).order("domelements.name").all
    @findstrategies = Findstrategie.where(:domaine_id => @domaine).all
  end
  
  def update
    @message=nil
    @popup = params[:popup].to_s
    idelement = params["idelement"]
    @majid = idelement
    name = params["name"]
    strategie = params["strategie"]
    path = params["path"]
    description = params["description"]
    @funcandscreen_id = params["funcandscreen_id"]
    @version_id = params["version_id"]
    
    @domelement = Domelement.where(:id => idelement).first
    if @domelement != nil
      @funcandscreen_id = @domelement.funcandscreen_id
      @version_id = @domelement.version_id
      @domelement.name = name
      @domelement.strategie = strategie
      @domelement.path = path
      @domelement.description = description
      @domelement.save
      ComputerLastGet.where(:domaine_id => @domaine, :object_type => "FuncAndScreen#{@domelement.funcandscreen_id}", :version_id => @version_id, :get => 0).update_all(:get => 1)
      @domelements = Domelement.where(:domaine_id => @domaine, :funcandscreen_id => @funcandscreen_id, :version_id => @version_id).order("domelements.name").all
      @findstrategies = Findstrategie.where(:domaine_id => @domaine).all
      @message = I18n.t "message.maj_effectuee"
      @OK=true
    else
      @domelements = Domelement.where(:funcandscreen_id => @funcandscreen_id, :version_id => @version_id).order("domelements.name").all
      @findstrategies = Findstrategie.where(:domaine_id => @domaine).all
      @message = I18n.t "message.operation_impossible"
      @OK=false
    end
    #	system('pause')
  end  
  
  def copy
    if params[:domelement_id] != nil
      @domelement = Domelement.where(:id => params[:domelement_id]).first
      if @domelement != nil
        cookies[:domelement_copy] = @domelement.id.to_s
        render html: 'ok', status: '200'
      end
    end
  end  

  def massiveinsert
    sheet_id = params[:sheet_id].to_s
    ext_node_id = params[:ext_node_id].to_s
    funcandscreen_id = params["funcandscreen_id"]
    version_id = params["version_id"]
    popup = params[:popup].to_s  
    elementslist = params["elementslist"] + "\n"
    elements = elementslist.to_s.split("\n")
    elementsnotinserted = ""
    ko = 0
    elements.each do |element|
      if element != "\n"
        element = element.gsub("\n", "") + " "
        telement = element.to_s.split("|;|")
        if telement.length == 4
          if telement[0] != '' and telement[1] != '' and telement[2] != '' and
              telement[0].length <= 50 and telement[2].length <= 500 and
              Findstrategie.where(:domaine_id => @domaine, :name => telement[1]).first != nil
            domelement = Domelement.new
            domelement.domaine_id = @domaine
            domelement.name = telement[0]
            domelement.strategie = telement[1]
            domelement.path = telement[2]
            domelement.description = telement[3].gsub("\n", "").gsub("\r", "").gsub("set_description", "")
            domelement.funcandscreen_id = funcandscreen_id
            domelement.version_id = version_id
            domelement.is_used = 0
            domelement.save
            domelement.current_id = domelement.id
            domelement.save
			ComputerLastGet.where(:domaine_id => @domaine, :object_type => "FuncAndScreen#{domelement.funcandscreen_id}", :version_id => @version_id, :get => 0).update_all(:get => 1)
          else
            elementsnotinserted += element + "\n"
            ko = 1
          end
        else
          elementsnotinserted += element + "\n"
          ko = 1
        end      
      end
      
    end
    redirect_to controller: 'domelements', action: 'index', popup: popup, sheet_id: sheet_id, ext_node_id: ext_node_id, elementslist: elementsnotinserted, ko: ko

  end  
  
  
end