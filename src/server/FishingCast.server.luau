local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FinalizeBobber = ReplicatedStorage.Remotes.CastBobber
local _FishingModule = require(game.ServerScriptService.Server.Modules.FishingModule)
local activeBobbers = {}

FinalizeBobber.OnServerEvent:Connect(function(player, data)
	if activeBobbers[player] then
		activeBobbers[player]:Destroy()
		activeBobbers[player] = nil
	end
	local bobber = Instance.new("Part")
	bobber.Name =  player.Name ..  " bobber"

	local tipAttachment = Instance.new("Attachment")
	local bobberAttachment = Instance.new("Attachment")
	local rope = Instance.new("RopeConstraint")
	rope.Name = player.Name .. " rope"

	FinalizeBobber:FireClient(player, {
		Bobber = bobber,
		rope = rope
	})

	if data.reel then
		bobber:Destroy()
		tipAttachment:Destroy()
		bobberAttachment:Destroy()
		rope:Destroy()
		return
	end

	
	bobber.Size = Vector3.new(0.3, 0.3, 0.3)
	bobber.Shape = Enum.PartType.Ball
	bobber.Position = data.Position
	bobber.CanCollide = true
	bobber.Parent = workspace.Casts
	
	
	tipAttachment.Parent = data.RodTipPart

	bobberAttachment.Parent = bobber

	rope.Attachment0 = tipAttachment
	rope.Attachment1 = bobberAttachment
	rope.Length = (tipAttachment.WorldPosition - bobberAttachment.WorldPosition).Magnitude + 1
	rope.Thickness = 0.05
	rope.Visible = true
	rope.Restitution = 0.2
	rope.Color = BrickColor.new("White")
	rope.Parent = bobber

	local updateConnection
	updateConnection = RunService.Heartbeat:Connect(function()
		if not rope or not bobber or not tipAttachment or not bobberAttachment then
			if updateConnection then updateConnection:Disconnect() end
			return
		end

		local targetLength = (tipAttachment.WorldPosition - bobberAttachment.WorldPosition).Magnitude + 1
		rope.Length = rope.Length + (targetLength - rope.Length)

		tipAttachment.WorldCFrame = data.RodTipPart.CFrame
	end)


	activeBobbers[player] = bobber
end)
