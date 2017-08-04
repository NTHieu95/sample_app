class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :find_user, only: :index

  attr_reader :user

  def index
    @users = user.send(params[:type]).paginate page: params[:page]
    @title = params[:type]
  end

  # def following
  #   @title = "Following"
  #   @user = User.find(params[:id])
  #   @users = user.following.paginate(page: params[:page])
  #   render "show_follow"
  # end

  # def followers
  #   @title = "Followers"
  #   @user = User.find(params[:id])
  #   @users = user.followers.paginate(page: params[:page])
  #   render "show_follow"
  # end

  def create
    active_relationships = current_user.active_relationships
    @user = User.find_by id: params[:followed_id]
    current_user.follow user
    @relationship_destroy = active_relationships.find_by followed_id: user.id
    respond_to do |format|
      format.html{redirect_to user}
      format.js
    end
  end

  def destroy
    active_relationships = current_user.active_relationships
    @user = Relationship.find_by(id: params[:id]).followed
    current_user.unfollow user
    @relationship_build = active_relationships.build
    respond_to do |format|
      format.html{redirect_to user}
      format.js
    end
  end

  private

  def find_user
    @user = User.find_by id: params[:id]

    return if user
    flash[:danger] = t "user_not_found"
    redirect_to root_url
  end
end
