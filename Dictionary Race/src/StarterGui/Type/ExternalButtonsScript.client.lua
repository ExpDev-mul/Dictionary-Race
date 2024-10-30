-->> Services
local tweenService = game:GetService("TweenService");

-->> References
local type = script.Parent;
local playerGui = type.Parent;

local externalButtons = type:WaitForChild("ExternalButtons");
local globalLeaderboard = externalButtons:WaitForChild("GlobalLeaderboard");

local globalLeaderboardsScreenGui = playerGui:WaitForChild("GlobalLeaderboards");
globalLeaderboardsScreenGui:WaitForChild("Main")

local store = externalButtons:WaitForChild("Store");
local storeScreenGui = playerGui:WaitForChild("Store");
storeScreenGui:WaitForChild("Main")

type:WaitForChild("BackFrame")

-->> Functions & Events
local current = nil;
function GlobalLeaderboardMouseButton1Down()
	if not current then
		current = "GlobalLeaderboards"
		tweenService:Create(type.BackFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
		tweenService:Create(globalLeaderboardsScreenGui.Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(0.5, 0.5)}):Play()
	else
		if current == "GlobalLeaderboards" then
			current = nil
			tweenService:Create(type.BackFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
			tweenService:Create(globalLeaderboardsScreenGui.Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(0.5, 1.5)}):Play()
		else
			tweenService:Create(playerGui[current].Main, TweenInfo.new(0, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(0.5, 1.5)}):Play()
			current = "GlobalLeaderboards"
			tweenService:Create(globalLeaderboardsScreenGui.Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(0.5, 0.5)}):Play()
		end;
	end;
end;

globalLeaderboard:WaitForChild("Events")
globalLeaderboard.Events.MouseButton1Down:Connect(GlobalLeaderboardMouseButton1Down)

local globalLeaderboardsEnabled = false;
function StoreMouseButton1Down()
	if not current then
		current = "Store"
		tweenService:Create(type.BackFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
		tweenService:Create(storeScreenGui.Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(0.5, 0.5)}):Play()
	else
		if current == "Store" then
			current = nil
			tweenService:Create(type.BackFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
			tweenService:Create(storeScreenGui.Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(0.5, 1.5)}):Play()
		else
			tweenService:Create(playerGui[current].Main, TweenInfo.new(0, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(0.5, 1.5)}):Play()
			current = "Store"
			tweenService:Create(storeScreenGui.Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(0.5, 0.5)}):Play()
		end;
	end;
end;

store:WaitForChild("Events")
store.Events.MouseButton1Down:Connect(StoreMouseButton1Down)