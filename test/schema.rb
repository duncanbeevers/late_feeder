ActiveRecord::Schema.define(:version => 0) do
  create_table :users, :force => true do |t|
    t.string :username
  end
end
