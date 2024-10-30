-->> Services
local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local marketPlaceService = game:GetService("MarketplaceService");
local badgeService = game:GetService("BadgeService");

-->> Modules
local dataStore2 = require(script:WaitForChild("DataStore2"));
local dataStoreService = game:GetService("DataStoreService");

local leaderboardData = replicatedStorage:WaitForChild("LeaderboardData");

-->> Functions & Events
local dataTemplate = {
	["Wins"] = 0,
	["Coins"] = 0,
}

local orderedWinsDataStore = dataStoreService:GetOrderedDataStore("_WinsOrderedDataStore")
local winsLeaderboard = {}
local updatingWinsLeaderboard = false

function WinsLeaderboardUpdate()
	local pages = orderedWinsDataStore:GetSortedAsync(false, 10, 1)
	pages = pages:GetCurrentPage()
	
	updatingWinsLeaderboard = true
	table.clear(winsLeaderboard)
	for position, data in next, pages do
		local username = "[ERROR]"
		pcall(function()
			username = players:GetNameFromUserIdAsync(data.key)
		end)
		
		table.insert(winsLeaderboard, {
			Name = username,
			Value = data.value,
			Position = position,
		})
	end;
	
	updatingWinsLeaderboard = false
	leaderboardData:FireAllClients(winsLeaderboard)
	task.wait(15)
	WinsLeaderboardUpdate()
end;

task.spawn(WinsLeaderboardUpdate)

function PlayerAdded(player)
	task.spawn(function()
		repeat
			task.wait()
		until not updatingWinsLeaderboard
		leaderboardData:FireClient(player, winsLeaderboard)
	end)
	
	local isVIP = false
	pcall(function()
		isVIP = marketPlaceService:UserOwnsGamePassAsync(player.UserId, 130722711)
	end)
	
	player:SetAttribute("VIP", isVIP)
	local statsDataStore = dataStore2("StatsDataStore", player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Parent = leaderstats
	
	if not badgeService:UserHasBadgeAsync(player.UserId, 3702255799) then
		local connection;
		local function WinsChanged()
			if wins.Value >= 100 then
				badgeService:AwardBadge(player.UserId, 3702255799)
				connection:Disconnect()
			end;
		end;

		connection = wins:GetPropertyChangedSignal("Value"):Connect(WinsChanged)
		WinsChanged()
	end;
	
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = leaderstats
	
	local data = statsDataStore:Get() or dataTemplate
	for stat, value in pairs(data) do
		leaderstats:FindFirstChild(stat).Value = value
	end;
end;

players.PlayerAdded:Connect(PlayerAdded)

function PlayerRemoving(player)
	local statsDataStore = dataStore2("StatsDataStore", player)
	local data = dataTemplate
	for _, stat in next, player.leaderstats:GetChildren() do
		data[stat.Name] = stat.Value
	end;
	
	statsDataStore:Set(data)
	task.spawn(function()
		orderedWinsDataStore:SetAsync(player.UserId, player.leaderstats.Wins.Value)
	end)
end;

players.PlayerRemoving:Connect(PlayerRemoving)

game:BindToClose(function()
	for _, player in next, players:GetChildren() do
		coroutine.wrap(function()
			PlayerRemoving(player)
		end)()
	end;
end)