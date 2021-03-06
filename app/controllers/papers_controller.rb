class PapersController < ApplicationController
  before_filter :require_user, :only => %w(new create update)
  before_filter :require_complete_profile, :only => %w(create)
  before_filter :require_admin_user, :only => %w(start_review archive)

  def recent
    @papers = Paper.recent.visible.paginate(
                :page => params[:page],
                :per_page => 10
              )

    @selected = "recent"

    respond_to do |format|
      format.atom { render :template => 'papers/index' }
      format.json { render :json => @papers }
      format.html { render :template => 'papers/index' }
    end
  end

  def index
    @papers = Paper.everything.paginate(
                :page => params[:page],
                :per_page => 10
              )

    @selected = "all"

    respond_to do |format|
      format.atom { render :template => 'papers/index' }
      format.json { render :json => @papers }
      format.html { render :template => 'papers/index' }
    end
  end

  def popular
    # TODO: Need to order by popularity here
    @papers = Paper.visible.paginate(
                :page => params[:page],
                :per_page => 10
              )

    @selected = "popular"

    respond_to do |format|
      format.atom { render :template => 'papers/index' }
      format.json { render :json => @papers }
      format.html { render :template => 'papers/index' }
    end
  end

  def submitted
    @papers = Paper.in_progress.paginate(
                :page => params[:page],
                :per_page => 10
              )

    @selected = "submitted"

    respond_to do |format|
      format.atom { render :template => 'papers/index' }
      format.json { render :json => @papers }
      format.html { render :template => 'papers/index' }
    end
  end

  def start_review
    @paper = Paper.find_by_sha(params[:id])

    if @paper.start_review!
      flash[:notice] = "Review started"
      redirect_to paper_path(@paper)
    else
      flash[:error] = "Review could not be started"
      redirect_to paper_path(@paper)
    end
  end

  def reject
    @paper = Paper.find_by_sha(params[:id])

    if @paper.reject!
      flash[:notice] = "Paper rejected"
      redirect_to paper_path(@paper)
    else
      flash[:error] = "Paper could not be rejected"
      redirect_to paper_path(@paper)
    end
  end

  def new
    @paper = Paper.new
  end

  def show
    @paper = Paper.find_by_sha(params[:id])
  end

  def create
    @paper = Paper.new(paper_params)

    @paper.submitting_author = current_user

    if @paper.save
      redirect_to paper_path(@paper)
    else
      render :action => :new
    end
  end

  def status
    @paper = Paper.find_by_sha(params[:id])

    # TODO: Remove these SVGs from the controller
    if @paper
      svg = @paper.status_badge
    else
      svg = '<svg xmlns="http://www.w3.org/2000/svg" width="102" height="20"><linearGradient id="b" x2="0" y2="100%"><stop offset="0" stop-color="#bbb" stop-opacity=".1"/><stop offset="1" stop-opacity=".1"/></linearGradient><mask id="a"><rect width="102" height="20" rx="3" fill="#fff"/></mask><g mask="url(#a)"><path fill="#555" d="M0 0h40v20H0z"/><path fill="#9f9f9f" d="M40 0h62v20H40z"/><path fill="url(#b)" d="M0 0h102v20H0z"/></g><g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11"><text x="20" y="15" fill="#010101" fill-opacity=".3">JOSS</text><text x="20" y="14">JOSS</text><text x="70" y="15" fill="#010101" fill-opacity=".3">Unknown</text><text x="70" y="14">Unknown</text></g></svg>'
    end

    if stale?(@paper)
      respond_to do |format|
        format.svg { render :inline => svg }
      end
    end
  end

  private

  def paper_params
    params.require(:paper).permit(:title, :repository_url, :archive_doi, :software_version, :body)
  end
end
