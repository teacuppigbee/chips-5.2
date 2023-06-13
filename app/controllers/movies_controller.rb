class MoviesController < ApplicationController
  before_action :check_home_page, only: [:index]
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  helper_method :column_header_class
  def column_header_class(column)
    return 'hilite' if column == @selected_column

    ''
  end

  def index
    @all_ratings = Movie.all_ratings
    
    if session[:home] == 0 && !params[:ratings]
      @selected_ratings = params[:ratings]
      @selected_column = params[:sort]
      session[:sort] = params[:sort]
      @movies = Movie.with_ratings(@selected_ratings)
      @ratings_to_show_hash = Hash[@all_ratings.map { |rating| [rating, false] }]
    else
      @selected_ratings = params[:ratings] || session[:ratings] || {}
      @selected_column = params[:sort] || session[:sort] # Store the selected column in an instance variable
      @movies = Movie.with_ratings(@selected_ratings.keys)
      @ratings_to_show_hash = Hash[@all_ratings.map { |rating| [rating, @selected_ratings.key?(rating)] }]
    
      case @selected_column
      when 'title'
        @movies = @movies.order(title: :asc)
      when 'release_date'
        @movies = @movies.order(release_date: :asc)
      end
    
      if params[:ratings].blank? && session[:ratings].present? && session[:ratings] != {}
        redirect_to movies_path(ratings: session[:ratings], sort: @selected_column)
        return
      end
    end
  
    session[:ratings] = @selected_ratings if params[:ratings].present?
    session[:sort] = @selected_column if params[:sort].present?
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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def check_home_page
    session[:home] = 0 
    session[:home] = 1 if request.referrer.present? && request.referrer.include?("/movies/")
  end


end