require "rjmetrics-client/client"
client = Client.new(0, "your-api-key")

# let's define some fake users
fake_users = [
	{:id => 1, :email => "joe@schmo.com", :acquisition_source => "PPC"},
	{:id => 2, :email => "mike@smith.com", :acquisition_source => "PPC"},
	{:id => 3, :email => "lorem@ipsum.com", :acquisition_source => "Referral"},
	{:id => 4, :email => "george@vandelay.com", :acquisition_source => "Organic"},
	{:id => 5, :email => "larry@google.com", :acquisition_source => "Organic"}
]

def sync_user(client, user)
	# `id` is the unique key here, since each user should only
	# have one record in this table
	user[:keys] = [:id]
	# table named "users"
	return client.pushData("users", user)
end

# make sure the client is authenticated before we do anything
if client.authenticated?
	fake_users.each do |user|
		# iterate through users and push data
		sync_user(client, user).each do |response|
			if response["code"]
				puts "Synced user with id #{user[:id]}"
			else
				puts "Failed to sync user with id #{user[:id]}"
			end
		end
	end
end
