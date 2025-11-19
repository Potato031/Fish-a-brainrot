local _humanoid = nil
local char = nil
local player = nil
local _rootPart = nil
local _mouse = nil
local _cam = workspace.CurrentCamera
local uis = game:GetService("UserInputService")
local idleAnim = nil
local forwardAnim = nil
local LeftAnim = nil
local RightAnim = nil


local wPressed = false
local sPressed = false
local aPressed = false
local dPressed = false
local equipped = false

script.Parent.Parent.Equipped:Connect(function()
	_humanoid = script.Parent.Parent.Parent.Humanoid
	player = game.Players:GetPlayerFromCharacter(script.Parent.Parent.Parent)
	char = script.Parent.Parent.Parent
	idleAnim = char:WaitForChild("Humanoid"):LoadAnimation(script.Parent.Parent.Anims:WaitForChild("IdleAnim"))
	forwardAnim = char:WaitForChild("Humanoid"):LoadAnimation(script.Parent.Parent.Anims:WaitForChild("ForwardAnim"))
	RightAnim = char:WaitForChild("Humanoid"):LoadAnimation(script.Parent.Parent.Anims:WaitForChild("ForwardAnim"))
	LeftAnim = char:WaitForChild("Humanoid"):LoadAnimation(script.Parent.Parent.Anims:WaitForChild("ForwardAnim"))
	_rootPart = script.Parent.Parent.Parent.HumanoidRootPart
	_mouse = player:GetMouse()
	equipped = true
	idleAnim:Play()
end)

script.Parent.Parent.Unequipped:Connect(function()
	equipped = false
	idleAnim:Stop()
	forwardAnim:Stop()
	LeftAnim:Stop()
	RightAnim:Stop()
end)

local currentAnim = nil

local function playUniqueAnim(anim)
	if currentAnim ~= anim then
		if currentAnim then
			currentAnim:Stop()
		end
		currentAnim = anim
		if currentAnim then
			currentAnim:Play()
		end
	end
end

local function updateMovementAnim()
	if wPressed or sPressed then
		playUniqueAnim(forwardAnim)
	elseif aPressed then
		playUniqueAnim(LeftAnim)
	elseif dPressed then
		playUniqueAnim(RightAnim)
	else
		playUniqueAnim(idleAnim)
	end
end

uis.InputBegan:Connect(function(key, chat)
	if not equipped or chat then return end

	if key.KeyCode == Enum.KeyCode.W then
		wPressed = true
	elseif key.KeyCode == Enum.KeyCode.S then
		sPressed = true
	elseif key.KeyCode == Enum.KeyCode.A then
		aPressed = true
	elseif key.KeyCode == Enum.KeyCode.D then
		dPressed = true
	end

	updateMovementAnim()
end)

uis.InputEnded:Connect(function(key, chat)
	if chat then return end

	if key.KeyCode == Enum.KeyCode.W then
		wPressed = false
	elseif key.KeyCode == Enum.KeyCode.S then
		sPressed = false
	elseif key.KeyCode == Enum.KeyCode.A then
		aPressed = false
	elseif key.KeyCode == Enum.KeyCode.D then
		dPressed = false
	end

	updateMovementAnim()
end)

