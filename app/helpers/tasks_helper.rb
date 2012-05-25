module TasksHelper

  # Returns a css style based on the tasks status
  # @param [Task] task to display
  # @return ['expired', nil]
  # @see Task#status
  def task_row_class(task)
    task.status
  end

  # Returns a css style based on a filter name
  # @param ['today', 'week', 'month'] name of a date filter 
  # @return ['active', nil] 'active' if the filter is active
  def is_active_date?(filter)
    'active' if params.has_value?(filter.to_s)
  end
  
  # Returns a css style when there is no active filter
  # @return ['active', nil] 'active' if there is no active filter
  def is_active_any_date?
    'active' unless params.has_key?('f')
  end

  # Returns the correct url path for a given filter name
  # @param ['today', 'week', 'month'] name of a date filter 
  # @return [Hash] a hash that represents a route tailored for a given filter
  #   * :controller [String] the name of the controller: 'tasks'
  #   * :action ['index', 'pending', 'done', 'expired'] the action requested on the controller 'tasks'
  #   * :name_cont [String] the search string that is part of the name of a task
  #   * :deadline_gteq [String] for search, the lower limit of the valid dateline range
  #   * :deadline_lteq [String] for search, the upper limit of the valid dateline rangeyy
  #   * :s ['deadline desc', 'deadline asc'] the sort_by field and asc/desc selector 
  #   * :f ['today', 'week', 'month'] the name of the date filter
  def date_filter_path(filter)
    if params[:q]
      case filter
        when :today
          params.merge(q: {deadline_eq: Date.today, name_cont: params[:q][:name_cont], s: params[:q][:s]}, 
                       f: :today).except(:page)
        when :week
          params.merge(q: {deadline_gteq: Date.today.beginning_of_week, deadline_lteq: Date.today.end_of_week, 
                           name_cont: params[:q][:name_cont], s: params[:q][:s]}, f: :week).except(:page)
        when :month
          params.merge(q: {deadline_gteq: Date.today.beginning_of_month, deadline_lteq: Date.today.end_of_month, 
                           name_cont: params[:q][:name_cont], s: params[:q][:s]}, f: :month).except(:page)
        when :any
          params[:q].except(:deadline_gteq, :deadline_lteq, :page, :name_cont, :s)
        else
          nil
      end
    end
  end
end
