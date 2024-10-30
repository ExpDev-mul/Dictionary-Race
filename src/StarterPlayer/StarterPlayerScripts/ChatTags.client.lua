local textChatService = game:GetService("TextChatService");
local marketPlaceService = game:GetService("MarketplaceService");
local players = game:GetService("Players");

textChatService.OnIncomingMessage = function(message)
	local properties = Instance.new("TextChatMessageProperties")
	if message.TextSource then
		if players:FindFirstChild(message.TextSource.Name):GetAttribute("VIP") then
			properties.PrefixText = "<font color='rgb(255, 200, 0)'>[🌟VIP] ".. message.TextSource.Name .."</font> "
		end;
	end;
	
	return properties
end