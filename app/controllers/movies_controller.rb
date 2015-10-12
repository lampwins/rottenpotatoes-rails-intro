class MoviesController < ApplicationController

  # See Section 4.5: Strong Parameters below for an explanation of this method:
  # http://guides.rubyonrails.org/action_controller_overview.html
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings
    @selected_checks = []
    
    if !params.has_key?("ratings") and session.has_key?("ratings")
      flash.keep
      redirect_to movies_path :sort => params[:sort].nil? ? session[:sort] : params[:sort], :ratings => session[:ratings].nil? ? @all_ratings : session[:ratings] and return
    end
    
    if params.has_key?("sort")
      session[:sort] = params[:sort]
    end
    
    if params.has_key?("ratings")
      session[:ratings] = params[:ratings]
      @selected_checks = session[:ratings]
    else
      session.delete(:ratings)
    end
    
    if session.has_key?("ratings")
      @ratings_sort = true
    end
    
    if session.has_key?("sort")
      if session[:sort] == "title"
        if @ratings_sort
          @movies = Movie.where(rating: session[:ratings].keys).order :title
        else
          @movies = Movie.order :title
        end
      elsif session[:sort] == "date"
        if @ratings_sort
          @movies = Movie.where(rating: session[:ratings].keys).order :release_date
        else
          @movies = Movie.order :release_date
        end
      end
    else
      if @ratings_sort
        @movies = Movie.where rating: session[:ratings].keys
      else
        @movies = Movie.all
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private :movie_params
  
end
