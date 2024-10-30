-->> Services
local tweenService = game:GetService("TweenService");

-->> References
local main = script.Parent;
local yes = main:WaitForChild("Yes");
local no = main:WaitForChild("No");
local greetText = main:WaitForChild("GreetText");

local backFrame = main.Parent:WaitForChild("BackFrame");
local clickPrevent = backFrame:WaitForChild("ClickPrevent");

-->> Functions & Events
local temporaryConnections = {}
table.insert(temporaryConnections, yes.MouseButton1Down:Connect(function()
	
end))

table.insert(temporaryConnections, no.MouseButton1Down:Connect(function()
	for _, connection in next, temporaryConnections do
		connection:Disconnect()
	end;
	
	tweenService:Create(no:WaitForChild("TextLabel"), TweenInfo.new(0.1, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	tweenService:Create(no, TweenInfo.new(1, Enum.EasingStyle.Back), {Position = UDim2.fromScale(0.249, 0.677), BackgroundTransparency = 1}):Play()
	task.wait(0.1)
	tweenService:Create(yes:WaitForChild("TextLabel"), TweenInfo.new(0.1, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	tweenService:Create(yes, TweenInfo.new(1, Enum.EasingStyle.Back), {Position = UDim2.fromScale(0.504, 0.677), BackgroundTransparency = 1}):Play()
	tweenService:Create(greetText, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	task.wait(0.3)
	tweenService:Create(backFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play()
	task.wait(0.5)
	clickPrevent.Visible = false
end))