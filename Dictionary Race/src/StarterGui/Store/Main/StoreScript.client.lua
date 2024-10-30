-->> Services
local marketPlaceService = game:GetService("MarketplaceService");
local players = game:GetService("Players");

-->> References
local main = script.Parent;
local vip = main:WaitForChild("VIP");

local localPlayer = players.LocalPlayer;

-->> Functions & Events
function VIPMouseButtonDown()
	marketPlaceService:PromptGamePassPurchase(localPlayer, 130722711)
end;

vip.MouseButton1Down:Connect(VIPMouseButtonDown)