Factory.define(:user) do |f|
  f.sequence :username do |n| "Allan #{n}" end
end
