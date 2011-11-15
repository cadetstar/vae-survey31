class GroupsController < ApplicationController
  before_filter :is_administrator?


  def index
    @groups = Group.order(:name)
  end

  def new
    g = Group.create
    redirect_to edit_group_path(g)
  end

  def edit
    unless @group = Group.find_by_id(params[:id])
      flash[:error] = 'I could not find a group with that ID.'
      redirect_to groups_path
    end
  end

  def update
    unless @group = Group.find_by_id(params[:id])
      flash[:error] = 'I could not find a group with that ID.'
      redirect_to groups_path
      return
    end
    if @group.update_attributes(params[:group])
      flash[:notice] = 'Group updated.'
      redirect_to groups_path
    else
      flash[:error] = 'The group could not be updated for some reason.'
      redirect_to edit_group_path(@group)
    end
  end

  def destroy
    unless @group = Group.find_by_id(params[:id])
      flash[:error] = 'I could not find a group with that ID.'
    else
      if @group.destroy
        flash[:notice] = 'Group destroyed.'
      else
        flash[:error] = 'Group not destroyed, probably has properties still attached.'
      end

    end
    redirect_to groups_path
  end
end