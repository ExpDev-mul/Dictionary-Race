-->> Services
local runService = game:GetService("RunService");
local tweenService = game:GetService("TweenService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local debris = game:GetService("Debris");

-->> References
local type = script.Parent;
local joinFrame = type:WaitForChild("JoinFrame");
local leaveFrame = type:WaitForChild("LeaveFrame");
local typeBox = type:WaitForChild("TypeBox");
local typeFrame = type:WaitForChild("TypeFrame");
local timerFrame = type:WaitForChild("TimerFrame");
local typerText = type:WaitForChild("TyperText");

local patternsLevel = type:WaitForChild("PatternsLevel");
local patternsLevelValue = replicatedStorage:WaitForChild("PatternsLevel");

local roundPurchases = type:WaitForChild("RoundPurchases");
local moreTenSeconds = roundPurchases:WaitForChild("MoreTenSeconds");

local coins = players.LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Coins");
moreTenSeconds.MouseButton1Click:Connect(function()
	if coins.Value >= 20 then
		replicatedStorage:WaitForChild("MoreTenSeconds"):FireServer()
	end;
end)

local addLife = roundPurchases:WaitForChild("AddLife");
addLife.MouseButton1Click:Connect(function()
	if coins.Value >= 50 then
		replicatedStorage:WaitForChild("MoreLife"):FireServer()
	end;
end)

local typeCharacter = script:WaitForChild("TypeCharacter");
local playerFrame = script:WaitForChild("PlayerFrame");
local heart = script:WaitForChild("Heart");

-->> Functions & Events
function PlaySound(soundName, createNew, startAt)
	if createNew then
		coroutine.wrap(function()
			local sound = script:WaitForChild(soundName.. "Sound")
			sound = sound:Clone()
			sound.Parent = game:GetService("SoundService")
			if startAt then
				sound.TimePosition = startAt
			end;
			
			sound:Play()

			debris:AddItem(sound, sound.TimeLength)
		end)()
	else
		script:WaitForChild(soundName.. "Sound"):Play()
	end;
end;

-->> Join Button
function JoinFrameEnter()
	tweenService:Create(joinFrame.UIGradient, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Offset = Vector2.new(-1, 0)}):Play()
	tweenService:Create(joinFrame.JoinText, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextColor3 = Color3.fromRGB(26, 26, 26)}):Play()
end;

joinFrame.MouseEnter:Connect(JoinFrameEnter)

function JoinFrameLeave()
	tweenService:Create(joinFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.fromScale(0.13, 0.08)}):Play()
	tweenService:Create(joinFrame.UIGradient, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Offset = Vector2.new(1, 0)}):Play()
	tweenService:Create(joinFrame.JoinText, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextColor3 = Color3.fromRGB(85, 255, 0)}):Play()
end;

joinFrame.MouseLeave:Connect(JoinFrameLeave)

function JoinButtonButtonDown()
	tweenService:Create(joinFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.fromScale(0.1, 0.07)}):Play()
end;

joinFrame.JoinButton.MouseButton1Down:Connect(JoinButtonButtonDown)

-->> Leave Button
function LeaveFrameEnter()
	tweenService:Create(leaveFrame.UIGradient, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Offset = Vector2.new(-1, 0)}):Play()
	tweenService:Create(leaveFrame.LeaveText, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextColor3 = Color3.fromRGB(26, 26, 26)}):Play()
end;

leaveFrame.MouseEnter:Connect(LeaveFrameEnter)

function LeaveFrameLeave()
	tweenService:Create(leaveFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.fromScale(0.13, 0.08)}):Play()
	tweenService:Create(leaveFrame.UIGradient, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Offset = Vector2.new(1, 0)}):Play()
	tweenService:Create(leaveFrame.LeaveText, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextColor3 = Color3.fromRGB(255, 0, 0)}):Play()
end;

leaveFrame.MouseLeave:Connect(LeaveFrameLeave)

function LeaveButtonButtonDown()
	tweenService:Create(leaveFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.fromScale(0.1, 0.07)}):Play()
end;

leaveFrame.LeaveButton.MouseButton1Down:Connect(LeaveButtonButtonDown)

local isRoundOn = nil
function Join()	
	isRoundOn = replicatedStorage.RoundOn:InvokeServer()
	
	if not isRoundOn then
		joinFrame.JoinButton.Visible = false

		JoinFrameLeave()
		replicatedStorage.RoundJoin:FireServer()
	else
		print("Round is on!")
	end;
end;

joinFrame.JoinButton.MouseButton1Click:Connect(Join)

function Leave()
	LeaveFrameLeave()
	if not isRoundOn then
		replicatedStorage.RoundLeave:FireServer()
	end;
end;

leaveFrame.LeaveButton.MouseButton1Click:Connect(Leave)

local roundPlayerFrames = {}
local typer = nil;
local PLAYERS_SCALE_DISTANCE_FROM_TIMER = 2.6;
local roundPlayers = {}
local pointerAngle = 0;

local typerPattern = nil;
local typingEnabled = false
local typeString = ""
function UpdateType(dt)
	local characters = {}
	local typeStringGoal = typeBox.Text;
	typeStringGoal = string.upper(typeStringGoal)
	
	if typeString == typeStringGoal then
		return
	end;
	
	PlaySound("Type", true)
	for x = 1, math.max(string.len(typeString), string.len(typeStringGoal)) do
		if string.sub(typeString, x, x) ~= "" and string.sub(typeStringGoal, x, x) ~= "" then
			if string.sub(typeString, x, x) ~= string.sub(typeStringGoal, x, x) then
				if typeFrame:FindFirstChild("char_".. x) then
					typeFrame:FindFirstChild("char_".. x):Destroy()
				end

				typeString = string.sub(typeStringGoal, 1, x)
				table.insert(characters, {Index = x, Value = string.sub(typeStringGoal, x, x)})
			end;
		elseif string.sub(typeStringGoal, x, x) ~= "" then
			-->> The character only exists for the string goal, thus we should fill the missing.
			for y = x, string.len(typeStringGoal) do
				table.insert(characters, {Index = y, Value = string.sub(typeStringGoal, y, y)})
			end

			typeString = typeStringGoal
			break
		elseif string.sub(typeString, x, x) ~= "" then
			-->> The character only exists for the string, thus we should remove the additional character.
			for y = string.len(typeString), string.len(typeStringGoal) + 1, -1 do
				if typeFrame:FindFirstChild("char_".. y) then
					typeFrame:FindFirstChild("char_".. y):Destroy()
				end;
			end;

			typeString = typeStringGoal
			break
		end;
	end;

	for _, character in next, characters do
		local newCharacterFrame = typeCharacter:Clone()
		newCharacterFrame.CharacterText.Text = character.Value
		newCharacterFrame.Name = "char_".. character.Index		
		newCharacterFrame.Parent = typeFrame
		tweenService:Create(newCharacterFrame, TweenInfo.new(0.1, Enum.EasingStyle.Bounce), {Size = UDim2.fromScale(1, newCharacterFrame.Size.Y.Scale)}):Play()
	end
	
	local s, e = string.find(string.lower(typeBox.Text), string.lower(typerPattern))
	if s and e then
		for x = s, e do
			if typeFrame:FindFirstChild("char_".. x) then
				typeFrame:FindFirstChild("char_".. x).CharacterText.TextColor3 = Color3.fromRGB(85, 255, 0)
			end;
		end

		for x = 1, s - 1 do
			if typeFrame:FindFirstChild("char_".. x) then
				typeFrame:FindFirstChild("char_".. x).CharacterText.TextColor3 = Color3.fromRGB(255, 0, 0)
			end;
		end;

		if e < string.len(typeBox.Text) then
			for x = e + 1, string.len(typeBox.Text) do
				if typeFrame:FindFirstChild("char_".. x) then
					typeFrame:FindFirstChild("char_".. x).CharacterText.TextColor3 = Color3.fromRGB(255, 0, 0)
				end;
			end;
		end;
	else
		for x = 1, string.len(typeBox.Text) do
			if typeFrame:FindFirstChild("char_".. x) then
				typeFrame:FindFirstChild("char_".. x).CharacterText.TextColor3 = Color3.fromRGB(255, 0, 0)
			end;
		end;
	end;
	
	if typingEnabled then
		for _, roundPlayerFrame in next, roundPlayerFrames do
			if roundPlayerFrame.Name == "player_".. typer.Name then
				roundPlayerFrame.Word.Text = typeStringGoal
			end;
		end;
		
		replicatedStorage.UpdateType:FireServer(typeStringGoal)
	end;
end;

function UpdatePlayers(dt)
	coroutine.wrap(function()
		if typer then		
			timerFrame.TimerPointer.Visible = true
			local angle = math.atan2((typer.Frame.AbsolutePosition.Y + typer.Frame.AbsoluteSize.Y/2) - (timerFrame.TimerPointer.AbsolutePosition.Y + timerFrame.TimerPointer.AbsoluteSize.Y/2), (typer.Frame.AbsolutePosition.X + typer.Frame.AbsoluteSize.X/2) - (timerFrame.TimerPointer.AbsolutePosition.X + timerFrame.TimerPointer.AbsoluteSize.X/2))
			pointerAngle = pointerAngle + (angle*180/math.pi - pointerAngle) * math.min(dt*10, 1)
			timerFrame.TimerPointer.Rotation = 90 + pointerAngle
			timerFrame.TimerPointer.Position = UDim2.fromScale(0.5 + math.cos(pointerAngle/180*math.pi)*0.5, 0.5 + math.sin(pointerAngle/180*math.pi)*0.5)
		else
			timerFrame.TimerPointer.Visible = false
		end;
	end)()
	
	for index, roundPlayer in next, roundPlayers do
		if not timerFrame:FindFirstChild("player_".. roundPlayer.Name) then
			-->> If the frame doesn't exist, create it
			PlaySound("JoinOrLeave", true)
			local newPlayerFrame = playerFrame:Clone();
			local success, _ = pcall(function()
				newPlayerFrame.PlayerCharacter.Image = players:GetUserThumbnailAsync(players:GetUserIdFromNameAsync(roundPlayer.Name), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			end)
			
			if not success then
				newPlayerFrame.PlayerCharacter:Destroy()
			end;
			
			if roundPlayer.Name == players.LocalPlayer.Name then
				newPlayerFrame:WaitForChild("UIStroke").Color = Color3.fromRGB(255, 255, 255)	
			end;
			
			newPlayerFrame.Username.Text = roundPlayer.Name
			newPlayerFrame.Name = "player_".. roundPlayer.Name
			local dx = 0.5 + math.cos(math.pi/2 -  2*math.pi/table.getn(roundPlayers)*index)*PLAYERS_SCALE_DISTANCE_FROM_TIMER
			local dy = 0.5 + math.sin(math.pi/2 - 2*math.pi/table.getn(roundPlayers)*index)*PLAYERS_SCALE_DISTANCE_FROM_TIMER
			newPlayerFrame.Parent = timerFrame
			table.insert(roundPlayerFrames, newPlayerFrame)
		else
			-->> If the frame exists, lerp the frame's position to it's goal position.
			coroutine.wrap(function()
				local dx = 0.5 + math.cos(math.pi/2 -  2*math.pi/table.getn(roundPlayers)*index)*PLAYERS_SCALE_DISTANCE_FROM_TIMER
				local dy = 0.5 + math.sin(math.pi/2 - 2*math.pi/table.getn(roundPlayers)*index)*PLAYERS_SCALE_DISTANCE_FROM_TIMER
				timerFrame:FindFirstChild("player_".. roundPlayer.Name).Position = timerFrame:FindFirstChild("player_".. roundPlayer.Name).Position:Lerp(UDim2.fromScale(dx, dy), dt*10)
			end)()
		end;
	end;
	
	for index, roundPlayerFrame in next, roundPlayerFrames do
		local roundPlayerFound = false
		for _, roundPlayer in next, roundPlayers do
			if "player_".. roundPlayer.Name == roundPlayerFrame.Name then
				roundPlayerFound = true
				break
			end;
		end;
		
		if not roundPlayerFound then
			roundPlayerFrame:Destroy()
			table.remove(roundPlayerFrames, index)
			PlaySound("JoinOrLeave", true)
			UpdatePlayers(dt)
		end;
	end;
end;

function TypeBoxFocusLost(entered)
	if entered then
		if string.match(string.lower(typeBox.Text), string.lower(typerPattern)) then
			local passed = replicatedStorage.TryWord:InvokeServer(typeBox.Text)
			typeBox.Text = ""
			if passed then
				PlaySound("Correct", true, 0.75)
			else
				PlaySound("Fail")
			end;
		else
			PlaySound("Fail")
			print("Pattern not found within word!")
		end;
	end;
end;

typeBox.FocusLost:Connect(TypeBoxFocusLost)

function UpdateHeartsOnClientEvent(serverRoundPlayers)
	for _, serverRoundPlayer in next, serverRoundPlayers do
		local roundPlayerFrame = timerFrame:WaitForChild("player_".. serverRoundPlayer.Name, 5)
		local hearts = 0
		for _, roundPlayerFrameHeart in next, roundPlayerFrame.Hearts:GetChildren() do
			if roundPlayerFrameHeart.Name == heart.Name then
				hearts += 1
			end;
		end;

		if hearts - serverRoundPlayer.Lives > 0 then
			for i = 1, hearts - serverRoundPlayer.Lives do
				if roundPlayerFrame.Hearts:FindFirstChild(heart.Name) then
					roundPlayerFrame.Hearts:FindFirstChild(heart.Name):Destroy()
				else
					break
				end;
			end;
		elseif hearts - serverRoundPlayer.Lives < 0 then
			for i = 1, math.abs(hearts - serverRoundPlayer.Lives) do
				local newHeart = heart:Clone()
				newHeart.Parent = roundPlayerFrame.Hearts
			end;
		end;
	end;
end;

replicatedStorage.UpdateHearts.OnClientEvent:Connect(UpdateHeartsOnClientEvent)

function RoundPlayersUpdateOnClientEvent(newRoundPlayers)
	roundPlayers = newRoundPlayers
	UpdateHeartsOnClientEvent(roundPlayers)
end;

replicatedStorage.RoundPlayersUpdate.OnClientEvent:Connect(RoundPlayersUpdateOnClientEvent)

function UpdateTyperOnClientEvent(typerName, pattern, serverPlayers)
	typerPattern = pattern
	for _, roundPlayerFrame in next, roundPlayerFrames do
		if roundPlayerFrame.Name == "player_".. typerName then
			typer = {Name = typerName, Frame = roundPlayerFrame}
			typerText.Text = "<i>".. typerName ..", type a word with <b>".. string.upper(pattern).. ".</b></i>"
		end;
	end;
	
	RoundPlayersUpdateOnClientEvent(serverPlayers)
	
	local characterCoefficient = "char_"
	for _, character in next, typeFrame:GetChildren() do
		if string.sub(character.Name, 1, string.len(characterCoefficient)) == characterCoefficient then
			character:Destroy()
		end
	end;
end;

replicatedStorage.UpdateTyper.OnClientEvent:Connect(UpdateTyperOnClientEvent)

function EnableTypeOnClientEvent()
	typingEnabled = true
	typeBox.TextEditable = true
	local function EnableType(dt)
		if not typeBox:IsFocused() then
			typeBox:CaptureFocus()
		end;
	end;
	
	runService:BindToRenderStep("EnableType", Enum.RenderPriority.First.Value, EnableType)
end;

replicatedStorage.EnableType.OnClientEvent:Connect(EnableTypeOnClientEvent)

function DisableTypeOnClientEvent()
	typingEnabled = false
	typeBox.TextEditable = false
	runService:UnbindFromRenderStep("EnableType")
end;

replicatedStorage.DisableType.OnClientEvent:Connect(DisableTypeOnClientEvent)

function UpdateTypeOnClientEvent(updatedPlayer, updatedText)
	if updatedPlayer then
		print(typer)
		if updatedPlayer.Name == typer.Name then
			for _, roundPlayerFrame in next, roundPlayerFrames do
				if roundPlayerFrame.Name == "player_".. typer.Name then
					roundPlayerFrame.Word.Text = updatedText
				end;
			end;

			typeBox.TextEditable = false
			typeBox.Text = updatedText
		end;
	end;
end;

replicatedStorage.UpdateType.OnClientEvent:Connect(UpdateTypeOnClientEvent)

function ClearTypeOnClientEvent()		
	typeBox.Text = ""
end;

replicatedStorage.ClearType.OnClientEvent:Connect(ClearTypeOnClientEvent)

local timerLength = nil;
local timerInitiateTick = nil;
function SetTimerOnClientEvent(length)
	length = math.floor(length)
	timerLength = length
	timerInitiateTick = tick()
end;

replicatedStorage.SetTimer.OnClientEvent:Connect(SetTimerOnClientEvent)

function RoundEndOnClientEvent()
	PlaySound("Correct")
	DisableTypeOnClientEvent()
	ClearTypeOnClientEvent()
	for _, roundPlayerFrame in next, roundPlayerFrames do
		roundPlayerFrame:Destroy()
	end;
	
	roundPlayerFrames = {}
	roundPlayers = {}
	typer = nil
	isRoundOn = false
	timerLength = nil
	timerInitiateTick = nil
	typerText.Text = ""
	joinFrame.Visible = true
	joinFrame.JoinButton.Visible = true
end;

replicatedStorage.RoundEnd.OnClientEvent:Connect(RoundEndOnClientEvent)

function FinishOnClientEvent()
	PlaySound("Finish")
end;

replicatedStorage.Finish.OnClientEvent:Connect(FinishOnClientEvent)

local patternLevelsColors = {
	["Normal"] = Color3.fromRGB(85, 170, 0),
	["Medium"] = Color3.fromRGB(255, 85, 0),
	["Hard"] = Color3.fromRGB(255, 0, 0),
	["Impossible"] = Color3.fromRGB(170, 0, 0),
}

function PatternLevelChanged()
	patternsLevel.Visible = not (patternsLevelValue.Value == "")
	if patternsLevel.Visible then
		patternsLevel.Text = "Patterns: ".. patternsLevelValue.Value
		patternsLevel.TextColor3 = patternLevelsColors[patternsLevelValue.Value]
	end;
end;

patternsLevelValue:GetPropertyChangedSignal("Value"):Connect(PatternLevelChanged)
PatternLevelChanged()

while true do
	local dt = runService.RenderStepped:Wait()
	
	local isLeaveFrameVisible = false
	for _, roundPlayer in next, roundPlayers do
		if roundPlayer.Name == players.LocalPlayer.Name then
			isLeaveFrameVisible = true
			break
		end;
	end;
	
	task.delay(0.25, function()
		leaveFrame.Visible = isLeaveFrameVisible and not isRoundOn
		if isLeaveFrameVisible and not isRoundOn then
			joinFrame.Visible = false
			joinFrame.JoinButton.Visible = true
		else
			joinFrame.Visible = true
		end;
	end)
	
	if replicatedStorage.Winner.Value ~= "" then
		type.WinnerText.Visible = true
		coroutine.wrap(function()
			if not type.WinnerText.WinnerImage.Loaded.Value  then
				type.WinnerText.WinnerImage.Loaded.Value = true
				local success, _ = pcall(function()
					type.WinnerText.WinnerImage.Image = players:GetUserThumbnailAsync(players:GetUserIdFromNameAsync(replicatedStorage.Winner.Value), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
				end)
				
				type.WinnerText.WinnerImage.Loaded.Value = success
			end;
		end)()
		type.WinnerText.Visible = true
		type.WinnerText.Text = replicatedStorage.Winner.Value.. " has won."
	else
		type.WinnerText.Visible = false
		type.WinnerText.Text = ""
		type.WinnerText.WinnerImage.Image = ""
		type.WinnerText.WinnerImage.Loaded.Value = false
	end;
	
	if timerLength and timerInitiateTick then
		local timeLeft = timerLength - (math.floor(tick() - timerInitiateTick))
		local lastText = timerFrame.TimerText.Text
		timerFrame.TimerText.Text = math.max(timeLeft, 1)
		
		if timeLeft < 5 then
			if lastText ~= timerFrame.TimerText.Text then
				PlaySound("Tick")
			end;
			
			timerFrame.TimerText.Rotation = math.sin(20*(tick() - timerInitiateTick - 5))*10
			timerFrame.TimerText.TextColor3 = timerFrame.TimerText.TextColor3:Lerp(Color3.fromRGB(255, 0, 0), dt*5)
			timerFrame.BombImage.ImageColor3 = timerFrame.BombImage.ImageColor3:Lerp(Color3.fromRGB(255, 0, 0), dt*5)
			timerFrame.BombImage.Rotation = math.sin(25*(tick() - timerInitiateTick - 5))*15
			timerFrame.BombImage.Size = timerFrame.BombImage.Size:Lerp(UDim2.fromScale(1.32, 1.32), dt*15)
		else
			timerFrame.TimerText.Rotation = timerFrame.Rotation - timerFrame.Rotation*dt
			timerFrame.TimerText.TextColor3 = timerFrame.TimerText.TextColor3:Lerp(Color3.fromRGB(255, 255, 255), dt*5)
			timerFrame.BombImage.ImageColor3 = timerFrame.BombImage.ImageColor3:Lerp(Color3.fromRGB(255, 255, 255), dt*5)
			timerFrame.BombImage.Rotation = timerFrame.BombImage.Rotation - timerFrame.BombImage.Rotation*dt*5
			timerFrame.BombImage.Size = timerFrame.BombImage.Size:Lerp(UDim2.fromScale(1.111, 1.111), dt*15)
		end;
		
		if timerLength - math.floor(tick() - timerInitiateTick) <= 0 then
			timerInitiateTick = nil
			timerLength = nil
		end;
	else
		timerFrame.TimerText.Text = ""
		timerFrame.TimerText.Rotation = timerFrame.Rotation - timerFrame.Rotation*dt
		timerFrame.BombImage.ImageColor3 = timerFrame.BombImage.ImageColor3:Lerp(Color3.fromRGB(255, 255, 255), dt*5)
		timerFrame.BombImage.Rotation = timerFrame.BombImage.Rotation - timerFrame.BombImage.Rotation*dt*5
		timerFrame.BombImage.Size = timerFrame.BombImage.Size:Lerp(UDim2.fromScale(1.111, 1.111), dt*15)
	end
	
	UpdateType(dt)
	UpdatePlayers(dt)
end;