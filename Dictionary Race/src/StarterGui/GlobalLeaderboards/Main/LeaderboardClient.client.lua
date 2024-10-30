-->> Services
local replicatedStorage = game:GetService("ReplicatedStorage");

-->> References
local leaderboardData = replicatedStorage:WaitForChild("LeaderboardData");

local main = script.Parent;
local winsLeaderboardContainer = main:WaitForChild("WinsLeaderboardContainer");

local playerFrame = script:WaitForChild("PlayerFrame");

-->> Functions & Events
local oldFrames = {}
function LeaderboardDataOnClientEvent(leaderboardData)
	for _, oldFrame in next, oldFrames do
		oldFrame:Destroy()	
	end;
	
	for _, playerData in next, leaderboardData do
		local newPlayerFrame = playerFrame:Clone()
		newPlayerFrame:WaitForChild("PositionText").Text = "#".. playerData.Position
		newPlayerFrame:WaitForChild("UsernameText").Text = playerData.Name
		newPlayerFrame:WaitForChild("ValueText").Text = playerData.Value
		newPlayerFrame.Parent =winsLeaderboardContainer
		table.insert(oldFrames, newPlayerFrame)
	end;
end;

leaderboardData.OnClientEvent:Connect(LeaderboardDataOnClientEvent)