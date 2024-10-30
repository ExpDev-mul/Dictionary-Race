-->> Services
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local httpService = game:GetService("HttpService");
local textService = game:GetService("TextService");
local badgeService = game:GetService("BadgeService");

-->> References
local roundJoin = replicatedStorage:WaitForChild("RoundJoin");
local roundLeave = replicatedStorage:WaitForChild("RoundLeave");
local roundPlayersUpdate = replicatedStorage:WaitForChild("RoundPlayersUpdate");
local enableType = replicatedStorage:WaitForChild("EnableType");
local disableType = replicatedStorage:WaitForChild("DisableType");
local updateType = replicatedStorage:WaitForChild("UpdateType");
local clearType = replicatedStorage:WaitForChild("ClearType");
local setTimer = replicatedStorage:WaitForChild("SetTimer");
local updateTyper = replicatedStorage:WaitForChild("UpdateTyper");
local roundEnd = replicatedStorage:WaitForChild("RoundEnd");
local updateHearts = replicatedStorage:WaitForChild("UpdateHearts");
local finish = replicatedStorage:WaitForChild("Finish");
local patternsLevel = replicatedStorage:WaitForChild("PatternsLevel");

local winner = replicatedStorage:WaitForChild("Winner");

local roundOn = replicatedStorage:WaitForChild("RoundOn");
local tryWord = replicatedStorage:WaitForChild("TryWord");
local moreTenSeconds = replicatedStorage:WaitForChild("MoreTenSeconds");
local moreLife = replicatedStorage:WaitForChild("MoreLife");

-->> Constants
local MIN_PLAYERS = 2;
local TURN_LENGTH = 8;

-->> Functions & Events
local START_LIVES = 3;
local MAX_LIVES = 6;

local lastTyped = nil;
local isRoundOn = false
local roundPlayers = {}
local usedWords = {}
function StopRound()
	print("Match ended!")
	isRoundOn = false
	roundPlayers = {}
	usedWords = {}
	lastTyped = nil
	roundEnd:FireAllClients()
end;

local patterns = {
	{
		Name = "Normal",
		Patterns = {"he", "she", "en", "ma", "ar", "ca", "in", "rea", "at", "wi", "tr", "ant"},
	},
	
	{
		Name = "Medium",
		Patterns = {"st", "ax", "ast", "ary", "nt", "bs", "ble", "si",  "str", "br", "int"},
	},
	
	{
		Name = "Hard",
		Patterns = {"ke", "de", "asm", "mer", "sm", "igh", "qu", "ue", "yc"},
	},
	
	{
		Name = "Impossible",
		Patterns = {"rcu", "ula", "ia", "isa", "riv", "eri", "su"}, 
	},
}

function GetLevelByTurns(turns)
	return patterns[1 + math.min(math.floor(turns / 10), table.getn(patterns) - 1)]
end;

function StartRound()
	print("Round started!")
	winner.Value = ""
	isRoundOn = true
	
	local turns = 0
	local currentLevel = GetLevelByTurns(turns)
	patternsLevel.Value = currentLevel.Name

	local initialRoundPlayers = table.getn(roundPlayers)
	local leftPlayersIndexes = {};
	
	local gameLoopConnections = {}
	local function GameLoop()
		turns += 1
		currentLevel = GetLevelByTurns(turns)
		patternsLevel.Value = currentLevel.Name
		for y = 1, table.getn(roundPlayers) do
			for _, leftPlayerIndex in next, leftPlayersIndexes do
				if y > leftPlayerIndex then
					 y -= 1
				end;
			end;
			
			if table.getn(roundPlayers) > 1 then
				if roundPlayers[y] and players:FindFirstChild(roundPlayers[y].Name) then					
					if lastTyped then
						clearType:FireAllClients()
						disableType:FireClient(lastTyped)
					end;
					

					local pattern = currentLevel.Patterns[math.random(1, #currentLevel.Patterns)];
					--print(roundPlayers[y].Name.. "'s turn.")
					updateTyper:FireAllClients(roundPlayers[y].Name, pattern, roundPlayers)
					enableType:FireClient(players:FindFirstChild(roundPlayers[y].Name))
					lastTyped = players:FindFirstChild(roundPlayers[y].Name)

					local passed = false
					local temporaryConnection
					local function TryWordOnServerInvoke(player, word)
						word = string.gsub(word, "%d", "") -->> Ignoring digits
						word = string.gsub(word, "%s", "") -->> Ignoring spaces/whitespaces
						word = string.gsub(word, "%p", "") -->> Ignoring punctuation
						if table.find(usedWords, word) then
							print("Already used.")
							return false
						end;
						
						local isWord, _ = pcall(function()
							httpService:GetAsync("https://api.dictionaryapi.dev/api/v2/entries/en/".. string.lower(word))
						end)
						
						if isWord then
							passed = true
							table.insert(usedWords, word)
						end;
						
						return isWord
					end;

					tryWord.OnServerInvoke = TryWordOnServerInvoke
					
					local boughtTenSeconds = 0
					table.insert(gameLoopConnections, moreTenSeconds.OnServerEvent:Connect(function(player)
						if player.leaderstats.Coins.Value >= 20 then
							player.leaderstats.Coins.Value -= 20
							boughtTenSeconds += 1
						end;
					end))
					
					table.insert(gameLoopConnections, moreLife.OnServerEvent:Connect(function(player)
						if player.leaderstats.Coins.Value >= 50 then
							for _, roundPlayer in next, roundPlayers do
								if roundPlayer.Name == player.Name then
									roundPlayer.Lives += 1
									player.leaderstats.Coins.Value -= 50
									updateHearts:FireAllClients(roundPlayers)
									return
								end;
							end;
						end;
					end))
					
					local currentTurnLength = TURN_LENGTH
					setTimer:FireAllClients(currentTurnLength)
					local startTick = tick()
					while tick() - startTick < currentTurnLength do
						task.wait()
						if boughtTenSeconds > 0 then
							currentTurnLength += 10*boughtTenSeconds
							boughtTenSeconds = 0
							setTimer:FireAllClients(currentTurnLength - (tick() - startTick))
						end;
						
						if passed then
							break
						end;
					end;
					
					tryWord.OnServerInvoke = nil
					if passed then
						--print("Nailed it!")
					else
						roundPlayers[y].Lives -= 1
						if roundPlayers[y].Lives <= 0 then
							--print("Removed")
							table.remove(roundPlayers, y)
						end;
					end;
					
					clearType:FireAllClients()
				else
					-->> Player has left the game while in a round.
					table.remove(roundPlayers, y)
					table.insert(leftPlayersIndexes, y)
					clearType:FireAllClients()
					roundPlayersUpdate:FireAllClients(roundPlayers)
				end;
			else
				if table.getn(roundPlayers) == 1 then
					local winnerPlayer = players:FindFirstChild(roundPlayers[1].Name)
					if winnerPlayer then
						task.spawn(function()
							if not badgeService:UserHasBadgeAsync(winnerPlayer.UserId) then
								badgeService:AwardBadge(winnerPlayer.UserId, 3702255799)
							end;
						end)
						
						winner.Value = roundPlayers[1].Name
						if players:FindFirstChild(roundPlayers[1].Name) then
							players:FindFirstChild(roundPlayers[1].Name).leaderstats.Wins.Value += 1
							players:FindFirstChild(roundPlayers[1].Name).leaderstats.Coins.Value += 10*(winnerPlayer:GetAttribute("VIP") and 2 or 1)
						end;

						finish:FireAllClients()
					end;
				end;
				
				return
			end;
		end;

		table.clear(leftPlayersIndexes)
		for _, connection in next, gameLoopConnections do
			connection:Disconnect()
		end;
		
		table.clear(gameLoopConnections)
		
		GameLoop()
	end;
	
	for _, connection in next, gameLoopConnections do
		connection:Disconnect()
	end;

	table.clear(gameLoopConnections)
	
	GameLoop()
	StopRound()
	patternsLevel.Value = ""
end;

function RoundJoinOnServerEvent(player)
	--print(player.Name.. " has joined the round.")
	table.insert(roundPlayers, {Name = player.Name, Lives = START_LIVES})
	roundPlayersUpdate:FireAllClients(roundPlayers)
	task.delay(5, function()
		if table.getn(roundPlayers) >= MIN_PLAYERS then
			if not isRoundOn then
				StartRound()
			end;
		end;
	end)
end;

roundJoin.OnServerEvent:Connect(RoundJoinOnServerEvent)

function RoundLeaveOnServerEvent(player)
	if not isRoundOn then
		for index, roundPlayer in next, roundPlayers do
			if roundPlayer.Name == player.Name then
				table.remove(roundPlayers, index)
				break
			end;
		end;
		
		roundPlayersUpdate:FireAllClients(roundPlayers)
	end;
end;

roundLeave.OnServerEvent:Connect(RoundLeaveOnServerEvent)

function UpdateTypeOnServerEvent(player, updatedText)
	local result
	local success, _ = pcall(function()
		result = textService:FilterStringAsync(updatedText, player.UserId)
	end)

	if success then
		updatedText = result:GetNonChatStringForBroadcastAsync()
	else
		return
	end;
	
	for _, otherPlayer in next, players:GetChildren() do
		if otherPlayer ~= player then
			updateType:FireClient(otherPlayer, player, updatedText)
		end;
	end;
end;

updateType.OnServerEvent:Connect(UpdateTypeOnServerEvent)

function RoundOnServerInvoke(player)
	return isRoundOn
end;

roundOn.OnServerInvoke = RoundOnServerInvoke

function PlayerAdded(player)
	roundPlayersUpdate:FireClient(player, roundPlayers)
end;

players.PlayerAdded:Connect(PlayerAdded)