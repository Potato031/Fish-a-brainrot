local player = game.Players.LocalPlayer
local pole = script.Parent.Parent
local FishingModule = require(game.ReplicatedStorage.Shared.Configs.FishingConfig)

local myRod = nil


local function isPressInput(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 
		or input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.Gamepad1
end

pole.Equipped:Connect(function()
	if not myRod then
		myRod = FishingModule:InitRod(pole, player, {
			power = 1.2,
			playerSize = UDim2.new(0.25, 0, 1, 0),
			fillRateMultiplier = 1.5,
			Splash = pole.Splash,
			Reel = pole.Reel,
			RodReel = pole["Fishing Rod Reel"]
		})
	end
end)

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if isPressInput(input) then
		if myRod then
			myRod:Move(1)  
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, processed)
	if processed then return end
	if isPressInput(input) then
		if myRod then
			myRod:Move(-1) 
		end
-- this sucks
	end
end)