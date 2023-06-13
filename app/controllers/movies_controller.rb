class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  helper_method :column_header_class
  def column_header_class(column)
    return 'hilite bg-warning' if column == @selected_column
    ''
  end

  def index
    @all_ratings = Movie.all_ratings

    selected_ratings = params[:ratings] || []

    # Fetch movies based on selected ratings
    @movies = Movie.with_ratings(selected_ratings)

    # Create a hash to track which ratings should be checked
    @ratings_to_show_hash = Hash[selected_ratings.map { |rating| [rating, true] }]

    @selected_column = params[:sort] # Store the selected column in an instance variable

    case @selected_column
    when 'title'
      @movies = @movies.order(title: :asc)
    when 'release_date'
      @movies = @movies.order(release_date: :asc)
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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

end
