local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFunction = ReplicatedStorage.Remotes.RequestCatch
local RequestBrainrot = ReplicatedStorage.Remotes.RequestBrainrot

local FishingModule = {}

FishingModule.RarityWeights = {
	Common = 50,
	Rare = 15,
	Epic = 4,
	Legendary = 1,
	Mythic = 0.5,
	["Brainrot God"] = 0.2,
	["Brainrot God (Lucky Box)"] = 0.1,
	Secret = 0.05
}
FishingModule.ImmunityDurations = {
	Common = 1,
	Rare = 1.8,
	Epic = 2.2,
	Legendary = 2.5,
	Mythic = 3.0,
	["Brainrot God"] = 3.5,
	["Brainrot God (Lucky Box)"] = 4.0,
	Secret = 5.0
}
FishingModule.BrainrotList = require(game.ServerScriptService.Server.Modules.BrainrotList).BrainrotsList

function FishingModule.GetEquippedRod(player)
	local character = player.Character
	if not character then return nil end
	for _, tool in ipairs(character:GetChildren()) do
		if tool:IsA("Tool") and tool:FindFirstChild("Luck") then
			return tool
		end
	end
	return nil
end

function FishingModule.GetWeightedBrainrot(rod)
	local luck = 1
	local luckAttr = rod:FindFirstChild("Luck")
	if luckAttr and luckAttr:IsA("NumberValue") then
		luck = luckAttr.Value
	end

	local totalWeight = 0
	for _, b in ipairs(FishingModule.BrainrotList) do
		totalWeight += (FishingModule.RarityWeights[b.rarity] or 0) * luck
	end

	local randomWeight = math.random() * totalWeight
	local cumulative = 0
	local chosen

	for _, b in ipairs(FishingModule.BrainrotList) do
		cumulative += (FishingModule.RarityWeights[b.rarity] or 0) * math.sqrt(luck)
		if randomWeight <= cumulative then
			chosen = table.clone(b)
			break
		end
	end

	if not chosen then
		chosen = table.clone(FishingModule.BrainrotList[1])
	end

	-- Weight multiplier
	local function getMultiplier()
		local roll = math.random()
		if roll < 0.70 / luck then
			return math.random(105, 175) / 100
		elseif roll < 0.88 / luck then
			return math.random(200, 600) / 100
		elseif roll < 0.97 / luck then
			return math.random(700, 2000) / 100
		elseif roll < 0.995 / luck then
			return math.random(2500, 5000) / 100
		elseif roll < 0.999999 / luck then
			return math.random(10000, 25000) / 100
		else
			return math.random(50000, 100000) / 100
		end
	end

	chosen.weightMultiplier = getMultiplier()
	chosen.finalWeight = chosen.baseWeight * chosen.weightMultiplier

	local function calculateScale(weight)
		local minScale = 0.1
		local maxScale = 25.0
		local startDiminish = 64
		if weight <= startDiminish then
			return minScale + (maxScale - minScale) * 0.05 * (weight / startDiminish)
		end
		local extra = weight - startDiminish
		local softMax = 5000
		local t = extra / (extra + softMax)
		local scale = minScale + (maxScale - minScale) * (0.05 + 0.95 * t)
		return math.clamp(scale, minScale, maxScale)
	end

	chosen.scale = calculateScale(chosen.finalWeight)
	return chosen
end

function FishingModule.AdjustToolGripToHand(tool, scale)
	local handle = tool:FindFirstChild("Handle")
	if not handle then return end
	local forwardOffset = (1 - scale) * 0.5
	local upwardOffset = (1 - scale) * -1
	tool.GripPos = Vector3.new(0, upwardOffset, -forwardOffset)
end

function FishingModule.TempScaleTool(tool, scale)
	if not tool.PrimaryPart then
		tool.PrimaryPart = tool:FindFirstChild("Handle")
	end
	if not tool.PrimaryPart then return end

	local tempModel = Instance.new("Model")
	tempModel.Name = "TempScaleModel"

	for _, part in ipairs(tool:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("MeshPart") then
			part.Parent = tempModel
		end
	end

	tempModel.PrimaryPart = tool.PrimaryPart
	tempModel:ScaleTo(scale)

	for _, part in ipairs(tempModel:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("MeshPart") then
			part.Parent = tool
		end
	end

	tool.PrimaryPart = tempModel.PrimaryPart
	tempModel:Destroy()
end





RemoteFunction.OnServerInvoke = function(player)
	local rod = FishingModule.GetEquippedRod(player)
	if not rod then return end
	local brainrot = FishingModule.GetWeightedBrainrot(rod)
	local brainRotFolder = ReplicatedStorage:WaitForChild("BrainRot")
	local toolToGive = brainRotFolder:FindFirstChild(brainrot.name)
	if not (toolToGive and toolToGive:IsA("Tool")) then return brainrot end

	local cloneTool = toolToGive:Clone()
	local truncatedWeight = string.format("%.1f", brainrot.finalWeight)
	cloneTool.Name = brainrot.name .. " " .. truncatedWeight .. "kg"

	FishingModule.TempScaleTool(cloneTool, brainrot.scale)
	FishingModule.AdjustToolGripToHand(cloneTool, brainrot.scale)
	cloneTool.Parent = player.Backpack
	return brainrot
end

RequestBrainrot.OnServerInvoke = function(player)
	local rod = FishingModule.GetEquippedRod(player)
	if not rod then return end
	local brainrot = FishingModule.GetWeightedBrainrot(rod)
	brainrot.immunityDuration = FishingModule.ImmunityDurations[brainrot.rarity] or 1
	return {
		name = brainrot.name,
		rarity = brainrot.rarity,
		moveSpeed = brainrot.moveSpeed,
		catchTime = brainrot.catchTime,
		immunityDuration = brainrot.immunityDuration,
		weightMultiplier = brainrot.weightMultiplier,
		finalWeight = brainrot.finalWeight
	}
end

return FishingModule
