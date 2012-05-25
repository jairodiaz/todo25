require 'spec_helper'

describe Task do
  it 'should be a valid task' do
    @task = build(:task)
    @task.should be_valid
  end

  it { should validate_presence_of(:name) }
  it { should ensure_length_of(:name).is_at_most(32) }
  it { should have_db_column(:done).of_type(:boolean).with_options(default: false) }

  describe 'scopes' do
    describe '.pending' do
      it "includes tasks that are pending/undone" do
        @task = create(:pending_task)
        Task.pending.should include(@task)
      end

      it "excludes tasks that are pending/undone" do
        @task = create(:done_task)
        Task.pending.should_not include(@task)
      end
    end

    describe '.done' do
      it "includes tasks that are done" do
        @task = create(:done_task)
        Task.done.should include(@task)
      end

      it "excludes tasks that are done" do
        @task = create(:pending_task)
        Task.done.should_not include(@task)
      end
    end

    describe '.expired' do
      it "includes tasks that are expired" do
        @task = create(:expired_task)
        Task.expired.should include(@task)
      end

      it "excludes tasks that are expired" do
        @task = create(:task)
        Task.expired.should_not include(@task)
      end
    end
  end

  describe '#status' do
    it 'should return an expired status for an expired task' do
      @task = create(:expired_task)
      @task.status.should == 'expired'
    end

    it 'should not return an expired status for an unexpired task' do
      @task = create(:task)
      @task.status.should == nil
    end
  end

  describe '#expired?' do
    it 'should return true for an expired task' do
      @task = create(:expired_task)
      @task.expired?.should be true
    end

    it 'should return false for an unexpired task' do
      @task = create(:task)
      @task.expired?.should be false
    end
  end

  describe '#mark_as_done' do
    it 'marks a pending task as done' do
      @task = create(:pending_task)
      @task.mark_as_done
      @task.should be_done
    end
  end
end
