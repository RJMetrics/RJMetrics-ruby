require "rjmetrics-client/client"
client = Client.new(0, "your-api-key")

fake_orders = [
	{:id => 1, :user_id => 1, :value => 58.40,  :sku => "milky-white-suede-shoes"},
	{:id => 2, :user_id => 1, :value => 23.99,  :sku => "red-button-down-fleece"},
	{:id => 3, :user_id => 2, :value => 5.00,   :sku => "bottle-o-bubbles"},
	{:id => 4, :user_id => 3, :value => 120.01, :sku => "zebra-striped-game-boy"},
	{:id => 5, :user_id => 5, :value => 9.90,   :sku => "kitten-mittons"}
]

def sync_order(client, order)
	order[:keys] = [:id]
	return client.pushData("orders", order)
end

if client.authenticated?
	fake_orders.each do |order|
		sync_order(client, order).each do |response|
			if response["code"]
				puts "Synced order with id #{order[:id]}"
			else
				puts "Failed to sync order with id #{order[:id]}"
			end
		end
	end
end
