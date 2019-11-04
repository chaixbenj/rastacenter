class PagesController < ApplicationController
  skip_before_action :require_login, only: [:doc, ]

  def doc
	reset_session
	@OK = params[:ok]
    @hors_appli = true
	@page = "doc"
  end

  end
