require 'spec_helper'

describe "Tasks", :clean_db do

  describe "A User" do
    describe "should be able to create a task so that he/she does not forget something to do" do
      before do
        visit root_path
        click_link t(:new_task)
        fill_in 'task_name', with: 'Buy milk'
        click_button t(:create_task)
      end

      subject {page}

      it 'should see the created task in the main list' do
        should have_content 'Buy milk'
      end
    end

    describe "should be able to create a task with a deadline so that he/she does not miss deadline" do
      before do
        visit root_path
        click_link t(:new_task)
        fill_in 'task_name', with: 'Buy milk'
        fill_in 'task_deadline', with: '2012-12-21'
        click_button t(:create_task)
      end

      subject {page}

      it 'should see the created task with deadline in the main list' do
        should_have_the_task_listed
      end
    end

    describe "should be able to edit a task so that he/she can change a task after it has been created" do
      let!(:task){create(:task, deadline: Date.tomorrow)}

      before do
        visit root_path
        click_link 'Edit'
        fill_in 'task_name', with: 'Buy milk'
        fill_in 'task_deadline', with: '2012-12-21'
        click_button t(:update_task)
      end

      subject {page}

      it 'should see the edited task in the main list' do
        should_have_the_task_listed
      end
    end

    describe "should be able to mark a task as done so that he/she can distinguish incomplete tasks from complete ones" do
      let!(:task){create(:task)}

      before do
        visit root_path
      end

      subject {page}

      it "should be able to mark a task as done from the main list", :js do
        check "checkbox_#{task.id}"
        sleep 1
        task.reload.should be_done
      end

      it "should not be in the pending list" do
        task.mark_as_done
        click_link t(:pending)
        should_not_have_the_task_listed
      end

      it "should be in the done list" do
        task.mark_as_done
        click_link t(:done)
        should_have_the_task_listed
      end
    end

    describe "should be able to see all tasks which didn't meet deadline as of today" do
      let!(:task){create(:expired_task)}

      subject {page}

      it "should be in the expired list" do
        visit expired_tasks_path
        should_have_the_expired_task_listed
      end

      it "should be in the all list" do
        visit tasks_path
        should_have_the_expired_task_listed
      end

      it "should not be in the pending list" do
        visit pending_tasks_path
        should_not_have_the_expired_task_listed
      end

      it "should not be in the done list" do
        visit done_tasks_path
        should_not_have_the_expired_task_listed
      end
    end

    describe "should be able to delete a task so that he/she can remove a task which is not a task anymore" do
      subject {page}

      describe 'deleted task should not be in any list' do
        it "should not be in the all list" do
          create(:task)
          visit root_path
        end

        it "should not be in the done list" do
          create(:done_task)
          visit done_tasks_path
        end

        it "should not be in the pending list" do
          create(:task)
          visit pending_tasks_path
        end

        it "should not be in the expired list" do
          create(:expired_task)
          visit expired_tasks_path
        end

        after do
          click_link t(:delete)
          should_not_have_the_task_listed
          Task.count.should be_zero
        end
      end
    end

    describe "should be able to see paginated results on all lists (8 per page)" do
      subject {page}

      it "in the all list" do
        create_tasks_for_two_pages

        visit tasks_path
        should_show_page_one

        click_link 'Next'
        should_show_page_two
      end

      it "in the expired list" do
        create_tasks_for_two_pages :expired_task

        visit expired_tasks_path
        should_show_page_one

        click_link 'Next'
        should_show_page_two
      end

      it "in the pending list" do
        create_tasks_for_two_pages :pending_task

        visit pending_tasks_path
        should_show_page_one

        click_link 'Next'
        should_show_page_two
      end

      it "in the done list" do
        create_tasks_for_two_pages :done_task

        visit done_tasks_path
        should_show_page_one

        click_link 'Next'
        should_show_page_two
      end

      def should_show_page_one
        8.times do |i|
          should have_content "Page 1 Task #{i}"
        end

        2.times do |i|
          should_not have_content "Page 2 Task #{8+i}"
        end
      end

      def should_show_page_two
        8.times do |i|
          should_not have_content "Page 1 Task #{i}"
        end
        2.times do |i|
          should have_content "Page 2 Task #{8+i}"
        end
      end

      # Type, expired_task, done_task, pending_task
      def create_tasks_for_two_pages(type = :task)
        8.times{ |i| create(type, name: "Page 1 Task #{i}") }
        2.times{ |i| create(type, name: "Page 2 Task #{8+i}") }
      end
    end

    describe "should be able to search tasks by name" do
      before do
        tasks = []
        tasks << create(:task, name: 'Use webkit')
        tasks << create(:task, name: 'Keep dOg')
        tasks << create(:task, name: 'Adopt kittens')
        tasks << create(:task, name: 'Call kid')
        tasks << create(:task, name: 'Feed dog')
      end

      before do
        visit root_path
      end

      subject {page}
      it 'should return results that contain kit' do
        fill_in 'q_name_cont', with: 'kit'
        click_button t(:search)
        should have_content 'Adopt kittens'
        should have_content 'Use webkit'
        should_not have_content 'Feed dog'
        should_not have_content 'Keep dOg'
        should_not have_content 'Call kid'
      end

      it 'should return results that contain something similar like DoG' do
        fill_in 'q_name_cont', with: 'DoG'
        click_button t(:search)
        should have_content 'Keep dOg'
        should have_content 'Feed dog'

        should_not have_content 'Adopt kittens'
        should_not have_content 'Use webkit'
        should_not have_content 'Call kid'
      end
    end

    context "filtering tasks by deadline" do
      before do
        @today_tasks = []
        @week_tasks = []
        @month_tasks = []

        @today_tasks << create(:task, name: 'Today 1', deadline: Date.today)
        @today_tasks << create(:task, name: 'Today 2', deadline: Date.today)
        @week_tasks << create(:task, name: 'Week 1', deadline: Date.today.end_of_week)
        @week_tasks << create(:task, name: 'Week 2', deadline: Date.today.end_of_week)
        @month_tasks << create(:task, name: 'Month 1', deadline: Date.today.end_of_month)
        @month_tasks << create(:task, name: 'Month 2', deadline: Date.today.end_of_month)

        @tasks = (@today_tasks + @week_tasks + @month_tasks).uniq # no duplicates please
        @tasks << create(:task, name: 'Other task', deadline: (Date.today.end_of_month + 2.weeks)) #one extra task far away from the range

        visit root_path
      end

      subject {page}

      it 'should be able to see all' do
        click_link t(:any)
        @tasks.each do |task|
          should have_content task.name
        end
      end

      it 'should be able to see only those for today' do
        click_link t(:today)
        @today_tasks.each do |task|
          should have_content task.name
        end

        (@tasks - @today_tasks).each do |task|
          should_not have_content task.name
        end
      end

      it 'should be able to see only those for the current week' do
        click_link t(:week)
        @week_tasks.each do |task|
          should have_content task.name
        end

        (@tasks - @week_tasks - @today_tasks).each do |task|
          should_not have_content task.name
        end
      end

      it 'should be able to see only those for the current month' do
        click_link t(:month)
        @month_tasks.each do |task|
          should have_content task.name
        end

        (@tasks - @month_tasks - @week_tasks - @today_tasks).each do |task|
          should_not have_content task.name
        end
      end
    end

    context "ordering tasks" do
      before do
        visit root_path
      end

      subject {page}

      context "by created at" do
        before do
          create(:task, name: 'Task two').update_attribute(:created_at, Time.now - 1.hour)
          create(:task, name: 'Task one').update_attribute(:created_at, Time.now - 2.hours)
          visit root_path
          click_link 'sort_created_at'
        end

        it 'should be able to sort them in ascendant order' do
          click_link 'sort_created_at'
          page.body.should match /Task two(.|\n)*Task one/
        end

        it 'should be able to sort them in descendant order' do
          page.body.should match /Task one(.|\n)*Task two/
        end
      end

      context "by deadline" do
        before do
          create(:task, name: 'Task one', deadline: Date.today)
          create(:task, name: 'Task two', deadline: Date.tomorrow)
          visit root_path
          click_link 'sort_deadline'
        end

        it 'should be able to sort them in ascendant order' do
          click_link 'sort_deadline'
          page.body.should match /Task one(.|\n)*Task two/
        end

        it 'should be able to sort them in descendant order' do
          page.body.should match /Task two(.|\n)*Task one/
        end
      end
    end

    def should_have_the_task_listed
      should have_content 'Buy milk'
      should have_content '21 December 2012'
    end

    def should_have_the_expired_task_listed
      should have_content 'Buy milk'
      should have_content Date.yesterday.strftime('%d %B %Y')
    end

    def should_not_have_the_expired_task_listed
      should_not have_content 'Buy milk'
      should_not have_content Date.yesterday.strftime('%d %B %Y')
    end

    def should_not_have_the_task_listed
      should_not have_content 'Buy milk'
      should_not have_content '21 December 2012'
    end
  end
end
