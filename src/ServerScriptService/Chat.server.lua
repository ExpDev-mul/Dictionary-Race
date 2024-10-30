-->> Services
local replicatedStorage = game:GetService("ReplicatedStorage");
local textService = game:GetService("TextService");
local players = game:GetService("Players");
local teleportService = game:GetService("TeleportService");

-->> References
local sendMessage = replicatedStorage:WaitForChild("SendMessage");

-->> Functions & Events
function FindClosestPlayerByName(name)
	-->> Receives a name and finds the player with the closest name
	local maxScore = -math.huge;
	local maxScorePlayer = nil;
	table.foreach(players:GetChildren(), function(_, player)
		local playerName = player.Name
		local score = 0;
		for i = math.min(1, math.min(string.len(playerName), string.len(name))), math.min(string.len(playerName), string.len(name)) do
			if string.sub(name, i, i) == string.sub(playerName, i, i) then
				score += 2
			elseif string.lower(string.sub(name, i, i)) == string.lower(string.sub(playerName, i, i)) then
				score += 1
			end;
		end;

		if score > maxScore then
			maxScore = score
			maxScorePlayer = player
		end;
	end)

	return maxScorePlayer
end;

-->> Modules
local authorizedIds = {
	467337150, -->> ComplexMetatable
}

local commands = require(script.Parent:WaitForChild("Commands"));
commands = {
	commands.new("kick", 1, function(author, player)
		if not table.find(authorizedIds, author.UserId) then
			return
		end;
		
		local kickPlayer = FindClosestPlayerByName(player);
		if kickPlayer then
			kickPlayer:Kick("You have been kicked from the server.")
			sendMessage:FireAllClients("Server", "'".. kickPlayer.. "' has been succesfully kicked from the server.", true)
		else
			sendMessage:FireAllClients("Server", "Could not find a player with a name close to '".. player .."'", true)
		end;
	end),
	
	commands.new("credits", 0, function(author)
		sendMessage:FireAllClients("Server", "This game was soley developed by ComplexMetatable.", true)
	end),
	
	commands.new("ping", 0, function(author)
		sendMessage:FireAllClients("Server", "Pong", true)
	end),
	
	commands.new("rejoin", 0, function(author)
		teleportService:TeleportToPlaceInstance(game.GameId, game.PrivateServerId, author)
	end),
	
	commands.new("tip", 0, function(author)
		local tips = {
			"Tip: Try to remember new words you see other players use.",
			"Tip: Learn how to spell the words you know.",
			"Tip: Non-characters will be ignored.",
		}
		
		sendMessage:FireAllClients("Server", tips[math.random(1, table.getn(tips))], true)
	end),
}

function SendMessageOnServerEvent(player, message)
	local unfilteredMessage = message
	
	local result
	local success, _ = pcall(function()
		result = textService:FilterStringAsync(message, player.UserId)
	end)
	
	if success then
		message = result:GetNonChatStringForBroadcastAsync()
		sendMessage:FireAllClients(player.Name, message)
		for _, command in next, commands do
			command:Verify(message, player)
		end;
	end;
end;

sendMessage.OnServerEvent:Connect(SendMessageOnServerEvent)

function PlayerAdded(player)
	sendMessage:FireAllClients("Server", "👋 ".. player.Name.. " has joined!", true)
end;

players.PlayerAdded:Connect(PlayerAdded)

function PlayerRemoving(player)
	sendMessage:FireAllClients("Server", "😔 ".. player.Name.. " has left.", true)
end;

players.PlayerRemoving:Connect(PlayerRemoving)