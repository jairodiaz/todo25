# Creates, edits, displays and deletes tasks.
# @see Task
class TasksController < ApplicationController

  before_filter :initialize_task, only: [:index, :done, :pending, :expired]
  before_filter :apply_filters, only: [:index, :done, :pending, :expired]

  # Shows all tasks
  def index
    @title = :all_tasks
  end

  # Edits one task
  def edit
    @task = Task.find(params[:id])
    session[:return_to] = request.referer
  end

  # Creates a new task
  def create
    @task = Task.new(params[:task])

    respond_to do |format|
      if @task.save
        format.html { redirect_to tasks_path, notice: t(:task_created) }
      else
        apply_filters
        format.html { render action: "index" }
      end
    end
  end

  # Updates a task's attributes
  def update
    @task = Task.find(params[:id])
    if @task.update_attributes(params[:task])
      respond_to do |format|
        format.js
        format.html { redirect_to session[:return_to], notice: t(:task_updated) }
      end
    else
      render action: "edit"
    end
  end

  # Destroys a task
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url }
    end
  end

  # Returns the list of tasks that have been done
  def done
    @title = :tasks_done
    @tasks = @tasks.done

    render 'index'
  end

  # Returns the list of pending tasks
  def pending
    @title = :pending_tasks
    @tasks = @tasks.pending

    render 'index'
  end

  # Returns the list of expired tasks
  def expired
    @title = :expired_tasks
    @tasks = @tasks.expired

    render 'index'
  end

  private
  # Instantiates a new task
  def initialize_task
    @task = Task.new
  end

  # Searches tasks by name, and the result is paginated and sorted by deadline
  def apply_filters
    params[:q] = params[:q] ? params[:q].reverse_merge({ s: 'deadline asc' }) : { s: 'deadline asc' }
    @search = Task.search(params[:q])
    @tasks = @search.result.paginate(:page => params[:page], :per_page => 8)
  end
end
