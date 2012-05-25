# A task to be managed
class Task < ActiveRecord::Base
  attr_accessible :deadline, :done, :name

  validates_presence_of :name
  validates_length_of :name, maximum: 32

  scope :pending, where('deadline >= ? AND done = ?', Time.now.utc.to_date, false)
  scope :done, where(done: true)
  scope :expired, where('deadline < ? AND done = ?', Time.now.utc.to_date, false)

  # Returns the task status
  # @return ['expired', nil] a constant 'expired' otherwise nil
  def status
    'expired' if deadline && self.expired?
  end

  # Computes if the task deadline has passed
  # @return [Boolean]
  def expired?
    self.deadline.try(:<, Time.now.utc.to_date) && !self.done?
  end

  # Marks the task as completed
  # @return [nil]
  def mark_as_done
    self.done = true
    save
  end
end
