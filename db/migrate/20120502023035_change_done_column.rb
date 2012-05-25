class ChangeDoneColumn < ActiveRecord::Migration
  change_table :tasks do |t|
    t.change :done, :boolean, default: false
  end
end
