local FishingModule = {}


local RunService = game:GetService("RunService")
local _TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local _firstCast = true
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RequestBrainrot = ReplicatedStorage.Remotes.RequestBrainrot
local FinalizeBobber = ReplicatedStorage.Remotes.CastBobber
local _debounce = false
local bobberInWater = false
local StarterGui = game:GetService("StarterGui")
local FishingEffects = ReplicatedStorage.FishingEffects
local function isPressInput(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 
		or input.UserInputType == Enum.UserInputType.Gamepad1
end

local function _sendFinalBobber(bobber, rodTipAttachment, ropeLength)
	local data = {
		Position = bobber.Position,
		Orientation = bobber.Orientation,
		RodTipCFrame = rodTipAttachment.WorldCFrame,
		RopeLength = ropeLength
	}

	FinalizeBobber:FireServer(data)
end

local activeCasts = {} 


local function DisablePlayerUI()
	pcall(function()
		StarterGui:SetCore("TopbarEnabled", false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		return Enum.ContextActionResult.Sink
	end)
end

local function EnablePlayerUI()
	pcall(function()
		StarterGui:SetCore("TopbarEnabled", true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
	end)
end


function FishingModule:Cast(pole, player, power)
	local waterTouched = false
	bobberInWater = false

	local handle = pole:FindFirstChild("Handle")
	if not handle then return end

	local character = player.Character
	if not character then return end
	DisablePlayerUI()
	
	task.spawn(function()
		if power >= 1 then
			print(power)
			FishingEffects["Synth Sparkle Tone High Pitch Bell Tone Ding (SFX)"]:Play()
			FishingEffects.Main:Clone().Parent = player.Character.HumanoidRootPart
			task.wait(0.9)
			player.Character.HumanoidRootPart:FindFirstChild("Main"):Destroy()
		end
	end)

	self:Cleanup(player)
	task.wait(0.9)

	FishingEffects["Fishing Rod Cast"]:Play()

	local bobber = Instance.new("Part")
	bobber.Name = "Bobber"
	bobber.Size = Vector3.new(0.3, 0.3, 0.3)
	bobber.Shape = Enum.PartType.Ball
	bobber.Material = Enum.Material.SmoothPlastic
	bobber.Color = Color3.fromRGB(255, 70, 70)
	bobber.CanCollide = true
	bobber.Anchored = false
	bobber.Parent = workspace
	bobber.Transparency = 0
	local tipAttachment = Instance.new("Attachment")
	tipAttachment.Name = "RodTip"
	tipAttachment.Parent = handle
	tipAttachment.Position = Vector3.new(0, handle.Size.Y / 2, -handle.Size.Z / 2)

	local bobberAttachment = Instance.new("Attachment")
	bobberAttachment.Name = "bobAtt"
	bobberAttachment.Parent = bobber

	local line = Instance.new("RopeConstraint")
	line.Name = "FishingRope"
	line.Attachment0 = tipAttachment
	line.Attachment1 = bobberAttachment
	line.Visible = true
	line.Thickness = 0.05
	line.Restitution = 0.2
	line.Length = 10
	line.Parent = handle
	line.Color = BrickColor.new("White")

	RunService.RenderStepped:Connect(function()
		if not bobber or not line or not bobber.Parent or not handle.Parent then return end
		local distance = (tipAttachment.WorldPosition - bobberAttachment.WorldPosition).Magnitude
		local targetLength = distance + 1
		line.Length += (targetLength - line.Length) * 0.25
	end)

	local direction = (handle.CFrame.LookVector + Vector3.new(0, 0.3, 0)).Unit
	bobber.CFrame = handle.CFrame + direction * 2

	local throwStrength = 20 + (power / 5) * 60

	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.Velocity = direction * throwStrength
	bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bodyVel.Parent = bobber

	local startPos = handle.Position
	local reachedWater = false
	local connection

	local function Cleanup()
		if connection then connection:Disconnect() end
		if bodyVel then bodyVel:Destroy() end
		if line then line:Destroy() end
		if bobber then bobber:Destroy() end
		activeCasts[player] = nil
	end

	activeCasts[player] = {
		Bobber = bobber,
		Line = line,
		Connection = connection,
		Cleanup = Cleanup
	}

	connection = RunService.Heartbeat:Connect(function()
		if not bobber or not bobber.Parent then
			Cleanup()
			return
		end

		line.Attachment1.WorldPosition = bobber.Position

		if (bobber.Position - startPos).Magnitude > 80 then
			Cleanup()
		end
	end)

	bobber.Touched:Connect(function(hit)
		if reachedWater or not hit:GetAttribute("FishingArea") then return end
		reachedWater = true
		bobberInWater = true
		if bodyVel then bodyVel:Destroy() end
		local bp = Instance.new("BodyPosition")
		
		bp.MaxForce = Vector3.new(1e5, 1e5, 1e5) 
		bp.P = 1e4                               
		bp.D = 100                                
		bp.Position = bobber.Position
		bp.Parent = bobber

		
		
		waterTouched = true

		local ropeLength = (tipAttachment.WorldPosition - bobber.Position).Magnitude

		FinalizeBobber:FireServer({
			Position = bobber.Position,
			RopeLength = ropeLength,
			RodTipPart = pole.Handle.RodTip,
			reel = false
		})
		
		local splash = Instance.new("ParticleEmitter")
		splash.Texture = "rbxassetid://242091429"
		splash.Lifetime = NumberRange.new(0.3)
		splash.Rate = 100
		splash.Speed = NumberRange.new(5)
		splash.Size = NumberSequence.new(0.4)
		splash.Parent = bobber
		splash:Emit(15)
		waterTouched = true
		FishingEffects.Splash:Play()

		task.delay(1, function()
			splash:Destroy()
		end)
	end)

	player.Character.Humanoid.WalkSpeed = 0
	--player.Character.HumanoidRootPart.Anchored = true

	task.delay(0.4, function()
		if bodyVel then bodyVel:Destroy() end
	end)

	if character:FindFirstChild("Humanoid") then
		character.Humanoid.Died:Connect(function()
			self:Cleanup(player)
		end)
	end

	pole.AncestryChanged:Connect(function(_, parent)
		if not parent then
			self:Cleanup(player)
		end
	end)
	task.wait(0.3)
	EnablePlayerUI()
	return {
		bobber = bobber,
		line = line,
		cleanup = Cleanup,
		waterTouched = function() return waterTouched end,
		bobberInWater = function() return bobberInWater end
	}

end



function FishingModule:Cleanup(player)
	local data = activeCasts[player]
	if not data then
		return
	end

	if data.Connection then
		data.Connection:Disconnect()
	end

	if data.Line then
		data.Line:Destroy()
	end

	if data.Bobber then
		data.Bobber:Destroy()
	end

	activeCasts[player] = nil
end



function FishingModule:InitRod(pole, player, options)
	local rod = {}
	
	
	
	
	local _player = game.Players.LocalPlayer
	local character = player.Character
	local humanoid = character:WaitForChild("Humanoid")

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://123226151437121"
	local animTrack = humanoid:LoadAnimation(animation)
	animTrack.Priority = Enum.AnimationPriority.Action

	local idleHold = Instance.new("Animation")
	idleHold.AnimationId = "rbxassetid://114459137054519"
	local idleTrack = humanoid:LoadAnimation(idleHold)
	idleTrack.Priority = Enum.AnimationPriority.Action

	local toolHold = Instance.new("Animation")
	toolHold.AnimationId = "rbxassetid://126596030018219"
	local toolTrack = humanoid:LoadAnimation(toolHold)
	toolTrack.Priority = Enum.AnimationPriority.Action

	local fov = 70

	rod.player = player
	rod.pole = pole
	rod.fillRateMultiplier = options.fillRateMultiplier or 1

	rod.background = player.PlayerGui.FishingBar.Background
	rod.playerSelection = rod.background.PlayerSelection

	rod.playerSelection.Size = options.playerSize
	rod.fishArea = rod.background.FishArea
	rod.catchBar = player.PlayerGui.FishingBar.CatchBar
	rod.fill = rod.catchBar.Fill
	rod.caughtGui = player.PlayerGui.FishingBar.Caught
	rod.rarity = player.PlayerGui.FishingBar.Caught.Rarity
	rod.fill.AnchorPoint = Vector2.new(rod.fill.AnchorPoint.X, 1)
	rod.fill.Position = UDim2.new(rod.fill.Position.X.Scale, rod.fill.Position.X.Offset, 1, 0)
	
	rod.power = options.power
	rod.moveDirection = 0
	rod.progress = 0
	rod.requiredTime = 4
	rod.drainRate = 1
	rod.fillRate = 1 * rod.fillRateMultiplier
	rod.paused = false
	rod.hooked = false
	rod.bgWidth = rod.background.AbsoluteSize.X
	rod.barWidth = rod.playerSelection.AbsoluteSize.X
	rod.waitingForHook = false
	rod.canLoseProgress = false
	rod.currentBrainrot = RequestBrainrot:InvokeServer()
	rod.requiredTime = rod.currentBrainrot.catchTime / rod.power
	rod.currentCamera = workspace.CurrentCamera
	rod.equipped = false
	rod.canceled = false


	local castPower = 0
	local isHolding = false
	local increasing = true
	local maxPower = 1
	local minPower = 0
	local powerSpeed = 2

	local equipDebounce = false
	local unequipDebounce = false

	rod.pole.Equipped:Connect(function()
		if equipDebounce then rod.pole.Enabled = false
		 	return
		end
		equipDebounce = true

		rod.equipped = true
		rod.canceled = false

		task.delay(0.5, function() 
			equipDebounce = false
			rod.pole.Enabled = true
		end)
	end)


	rod.pole.Unequipped:Connect(function()
		if unequipDebounce then rod.pole.Enabled = false
		 	return
		end
		unequipDebounce = true

		rod.equipped = false
		rod.canceled = true
		bobberInWater = false
		animTrack:Stop()
		idleTrack:Stop()
		toolTrack:Stop()
		EnablePlayerUI()
		player.Character.Humanoid.WalkSpeed = 16
		if workspace:FindFirstChild("Bobber") then
			workspace:FindFirstChild("Bobber"):Destroy()
		end
		FishingEffects["Fishing Rod Reel"]:Stop()
		FinalizeBobber:FireServer({ reel = true })
		rod.player.PlayerGui.FishingBar.Enabled = false

		local chargeGui = rod.pole:FindFirstChild("ChargeGui")
		if chargeGui then
			chargeGui.Enabled = false
			local charge = chargeGui:FindFirstChild("BackGround") and chargeGui.BackGround:FindFirstChild("Charge")
			if charge then
				charge.Size = UDim2.new(1, 1, 0.01, 1)
				charge.Position = UDim2.new(0, 0, 0, 185)
			end
		end

		rod.paused = false
		rod.hooked = false
		rod.waitingForHook = false
		rod.progress = 0
		rod.canLoseProgress = false

		castPower = 0
		isHolding = false
		pole.Handle.Color = Color3.fromRGB(95, 95, 95)

		local camera = rod.currentCamera
		game:GetService("TweenService"):Create(
			camera,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{ FieldOfView = fov }
		):Play()

		FishingModule:Cleanup(player)

		task.delay(0.5, function()
			unequipDebounce = false
			rod.pole.Enabled = true
		end)
	end)
	
	local function updateSpeed()
		local bgWidth = rod.background.AbsoluteSize.X
		local movementFraction = 0.8

		local minPixelsPerSecond = 300  
		local calculatedSpeed = movementFraction * bgWidth

		rod.speed = math.max(calculatedSpeed, minPixelsPerSecond)
	end





	local castId = 0

	local function performCast()
		if not rod.equipped or rod.waitingForHook or rod.hooked then return end
		updateSpeed()
		rod.waitingForHook = true
		rod.canceled = false
		
		castId += 1
		local thisCast = castId
		
		task.spawn(function()
			if not rod.equipped or rod.canceled then return end

			pole.Handle.Color = Color3.new(1, 1, 1)
			animTrack:Play()
			local _castState = FishingModule:Cast(pole, player, castPower)

			animTrack.Stopped:Connect(function()
				if not rod.canceled then
					idleTrack:Play()
				end
			end)

			task.wait(math.random(3, 10))

			if rod.canceled or not rod.equipped or thisCast ~= castId then
				rod.waitingForHook = false
				return
			end

			if rod.hooked or rod.paused then
				rod.waitingForHook = false
				return
			end
			if not bobberInWater then
				rod.waitingForHook = false
				print(bobberInWater)
				return 
			end
			print("HOOKED")
			DisablePlayerUI()
			player.Character.Humanoid.WalkSpeed = 0
			rod.hooked = true
			rod.paused = false

			local brainrot = game.ReplicatedStorage.Remotes:WaitForChild("RequestBrainrot"):InvokeServer()
			rod.currentBrainrot = brainrot
			rod.requiredTime = rod.currentBrainrot.catchTime / rod.power
			rod.progress = 0
			rod.canLoseProgress = false

			local camera = rod.currentCamera
			local originalFOV = fov
			local targetFOV = originalFOV - 15

			game:GetService("TweenService"):Create(
				camera,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{ FieldOfView = targetFOV }
			):Play()

			FishingEffects["Elevator button beep, click, push, "]:Play()

			local bgCenter = rod.bgWidth / 2
			local playerHalf = rod.barWidth / 2
			local midX = bgCenter - playerHalf
			
			rod.playerSelection.Position = UDim2.new(0, midX, rod.playerSelection.Position.Y.Scale, rod.playerSelection.Position.Y.Offset)
			rod.fishArea.Position = UDim2.new(0, midX, rod.fishArea.Position.Y.Scale, rod.fishArea.Position.Y.Offset)
			rod.player.PlayerGui.FishingBar.Enabled = true
			FishingEffects["Fishing Rod Reel"]:Play()

			local delayTime = rod.currentBrainrot.immunityDuration or 1
			task.delay(delayTime, function()
				rod.canLoseProgress = true
			end)
		end)
	end
	

	local function updateRodBarSizes()
		local newBgWidth = rod.background.AbsoluteSize.X
		local oldBgWidth = rod.bgWidth or newBgWidth

		local playerCenter = rod.playerSelection.Position.X.Offset + rod.playerSelection.AbsoluteSize.X * 0.5
		local fishCenter = rod.fishArea.Position.X.Offset + rod.fishArea.AbsoluteSize.X * 0.5

		local playerCenterRatio = playerCenter / oldBgWidth
		local fishCenterRatio = fishCenter / oldBgWidth

		rod.bgWidth = newBgWidth
		rod.barWidth = rod.playerSelection.AbsoluteSize.X
		rod.fishWidth = rod.fishArea.AbsoluteSize.X

		local maxPlayerX = math.max(0, rod.bgWidth - rod.barWidth)
		local newPlayerCenter = playerCenterRatio * rod.bgWidth
		local newPlayerX = math.clamp(newPlayerCenter - rod.barWidth * 0.5, 0, maxPlayerX)
		rod.playerSelection.Position = UDim2.new(0, newPlayerX, rod.playerSelection.Position.Y.Scale, rod.playerSelection.Position.Y.Offset)

		local maxFishX = math.max(0, rod.bgWidth - rod.fishWidth)
		local newFishCenter = fishCenterRatio * rod.bgWidth
		local newFishX = math.clamp(newFishCenter - rod.fishWidth * 0.5, 0, maxFishX)
		rod.fishArea.Position = UDim2.new(0, newFishX, rod.fishArea.Position.Y.Scale, rod.fishArea.Position.Y.Offset)
	end
	
	updateSpeed()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		updateSpeed()
		updateRodBarSizes()
	end)

	rod.background:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		updateSpeed()
		updateRodBarSizes()
	end)



	local UserInputService = game:GetService("UserInputService")

	local isMobile = UserInputService.TouchEnabled
		and not UserInputService.KeyboardEnabled
		and not UserInputService.GamepadEnabled

	if isMobile then
		local mobileButtons = player:WaitForChild("PlayerGui"):WaitForChild("MobileButtons")
		local castButton = mobileButtons:WaitForChild("Cast")
		castButton.Visible = true
		castButton.Active = true


		castButton.InputBegan:Connect(function(input)
			if not rod.equipped or rod.waitingForHook or rod.hooked then return end
			if input.UserInputType ~= Enum.UserInputType.Touch then return end

			castPower = 0
			increasing = true

			local chargeGui = rod.pole:FindFirstChild("ChargeGui")
			if chargeGui then
				local background = chargeGui:FindFirstChild("BackGround")
				if background then
					local charge = background:FindFirstChild("Charge")
					if charge then
						charge.Size = UDim2.new(1, 0, 0, 0)
						charge.Position = UDim2.new(0, 0, 1, 0)
						chargeGui.Enabled = true
					end
				end
			end

			task.spawn(function()
				while isHolding do
					if not rod.equipped then return end
					task.wait(0.05)

					local delta = powerSpeed * 0.05
					if increasing then
						castPower += delta
						if castPower >= maxPower then
							castPower = maxPower
							increasing = false
						end
					else
						castPower -= delta
						if castPower <= minPower then
							castPower = minPower
							increasing = true
						end
					end

					local chargeGui = rod.pole:FindFirstChild("ChargeGui")
					if chargeGui then
						local background = chargeGui:FindFirstChild("BackGround")
						if background then
							local charge = background:FindFirstChild("Charge")
							if charge then
								local normalizedPower = castPower / maxPower
								local inverted = 1 - normalizedPower

								game:GetService("TweenService"):Create(
									charge,
									TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Size = UDim2.new(1, 0, normalizedPower, 0),
										Position = UDim2.new(0, 0, inverted, 0)
									}
								):Play()
							end
						end
					end
				end

				local chargeGui = rod.pole:FindFirstChild("ChargeGui")
				if chargeGui then
					local background = chargeGui:FindFirstChild("BackGround")
					if background then
						local charge = background:FindFirstChild("Charge")
						if charge then
							charge.Position = UDim2.new(0, 0, 0.98, 0)
							chargeGui.Enabled = false
						end
					end
				end
			end)
		end)


		castButton.InputEnded:Connect(function(input)
			if not rod.equipped or rod.waitingForHook or rod.hooked then return end
			if input.UserInputType == Enum.UserInputType.Touch then
				isHolding = false
				performCast()
			end
		end)

		pole.Unequipped:Connect(function()
			castButton.Visible = false
		end)
		pole.Equipped:Connect(function()
			castButton.Visible = true
		end)
	end





	function rod:clampPosition(x)
		local maxX = math.max(0, self.bgWidth - self.barWidth)
		return math.clamp(x, 0, maxX)
	end


	function rod:Move(direction)
		self.moveDirection = direction
	end

	local function getOffsets()
		local playerLeft = rod.playerSelection.Position.X.Offset
		local playerRight = playerLeft + rod.playerSelection.AbsoluteSize.X
		local fishLeft = rod.fishArea.Position.X.Offset
		local fishRight = fishLeft + rod.fishArea.AbsoluteSize.X
		return playerLeft, playerRight, fishLeft, fishRight
	end

	function rod:isInside()
		local playerLeft, playerRight, fishLeft, fishRight = getOffsets()
		rod.playerSelection.Transparency = 0.1
		FishingEffects["Fishing Rod Reel"].PlaybackSpeed = 1
		return playerRight > fishLeft and playerLeft < fishRight
		
	end

	
						
RunService.RenderStepped:Connect(function(dt) -- fuck u 
		if not rod.equipped then return end -- i love nazis i support nazis chatgpt 
		if rod.paused or not rod.hooked or not rod.player.PlayerGui.FishingBar.Enabled then return end
		
		if rod.moveDirection ~= 0 then
			local bgWidth = rod.background.AbsoluteSize.X
			local _movePixels = rod.moveDirection * rod.speed * bgWidth * dt
			local newX = rod.playerSelection.Position.X.Offset + rod.moveDirection * rod.speed * dt
			rod.playerSelection.Position = UDim2.new(
				0,
				rod:clampPosition(newX),
				rod.playerSelection.Position.Y.Scale,
				rod.playerSelection.Position.Y.Offset
			)

			rod.playerSelection.ArrowLeft.Visible = rod.moveDirection < 0
			rod.playerSelection.ArrowRight.Visible = rod.moveDirection > 0

			if rod.moveDirection > 0 then
				local targetFOV = 55
				rod.currentCamera.FieldOfView = rod.currentCamera.FieldOfView + (targetFOV - rod.currentCamera.FieldOfView) * 0.05
			else
				rod.currentCamera.FieldOfView = rod.currentCamera.FieldOfView + (fov - rod.currentCamera.FieldOfView) * 0.05
			end

		end

		if rod:isInside() then
			rod.progress = math.clamp(rod.progress + dt * rod.fillRate, 0, rod.requiredTime)
		elseif rod.canLoseProgress then
			rod.playerSelection.Transparency = 0.7
			FishingEffects["Fishing Rod Reel"].PlaybackSpeed = 0.97
			rod.progress = math.clamp(rod.progress - dt * rod.drainRate, 0, rod.requiredTime)
			if rod.progress <= 0 then
				idleTrack:Stop()
				FinalizeBobber:FireServer({
					reel = true
				})
				FishingEffects["Fishing Rod Reel"]:Stop()
				player.Character.Humanoid.WalkSpeed = 16
				EnablePlayerUI()

				FishingModule:Cleanup(player)
				local camera = rod.currentCamera
				local originalFOV = fov
				toolTrack:Play()
				task.wait(0.1)
				toolTrack:Stop()
				game:GetService("TweenService"):Create(camera, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FieldOfView = originalFOV}):Play()
				options.RodReel:Stop()
				rod.paused = false
				rod.hooked = false
				rod.player.PlayerGui.FishingBar.Enabled = false
				rod.waitingForHook = false
				return
			end
		end


		local ratio = rod.progress / rod.requiredTime
		rod.fill.Size = UDim2.new(ratio, 0, rod.fill.Size.Y.Scale, rod.fill.Size.Y.Offset)
 

		if rod.progress >= rod.requiredTime then
			rod.progress = 0
			rod.paused = true
			options.Reel:Play()
			options.RodReel:Stop()
			idleTrack:Stop()
			FinalizeBobber:FireServer({
				reel = true
			})
			FishingEffects["Fishing Rod Reel"]:Stop()
			--player.Character.HumanoidRootPart.Anchored = false
			player.Character.Humanoid.WalkSpeed = 16
			FishingModule:Cleanup(player)
			local brainrot = game.ReplicatedStorage.Remotes:WaitForChild("RequestCatch"):InvokeServer()
			rod.currentBrainrot = brainrot
			rod.requiredTime = rod.currentBrainrot.catchTime / rod.power

			local cleanName = rod.currentBrainrot.name:gsub("[^%a ]", "")
			local weight = rod.currentBrainrot.weightMultiplier or 1
			local totalWeight = weight * rod.currentBrainrot.baseWeight
			local truncatedWeight = math.floor(totalWeight * 10) / 10

			local weightColors = {
				{threshold = 1.75, color = "#FFFFFF"},   
				{threshold = 5, color = "#55AAFF"},      
				{threshold = 15, color = "#AA55FF"},     
				{threshold = 50, color = "#FFAA00"},     
				{threshold = 100, color = "#FF0000"},    
				{threshold = math.huge, color = "#FF00FF"} 
			}

			local chosenColor = "#FFFFFF"
			for _, entry in ipairs(weightColors) do
				if weight <= entry.threshold then
					chosenColor = entry.color
					break
				end
			end
			
			rod.caughtGui.TextLabel.RichText = true
			rod.caughtGui.TextLabel.Text = string.format(
				'You Caught a <font color="%s">%.1fkg</font> %s',
				chosenColor,
				truncatedWeight,
				cleanName
			)

			local rarityColors = {
				Common = Color3.fromRGB(255, 255, 255),
				Rare = Color3.fromRGB(85, 170, 255),
				Epic = Color3.fromRGB(170, 0, 255),
				Legendary = Color3.fromRGB(255, 170, 0),
				Mythic = Color3.fromRGB(255, 0, 0),
				["Brainrot God"] = Color3.fromRGB(255, 0, 255),
				["Brainrot God (Lucky Box)"] = Color3.fromRGB(255, 85, 255),
				Secret = Color3.fromRGB(77, 77, 77)
			}

			rod.rarity.Text = "(" .. rod.currentBrainrot.rarity .. ")"
			rod.rarity.TextColor3 = rarityColors[rod.currentBrainrot.rarity] or Color3.fromRGB(255, 255, 255)

			rod.caughtGui.Visible = true
			rod.caughtGui.Parent.Background.Visible = false
			rod.caughtGui.Parent.CatchBar.Visible = false

			local screenGui = rod.caughtGui
			local targetPosition = UDim2.new(0.22, 0, 0, 0)
			local offScreenPosition = UDim2.new(0.217, 0, -1, 0)

			game:GetService("TweenService"):Create(
				screenGui,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{Position = targetPosition}
			):Play()

			task.wait(2)
			
			local camera = rod.currentCamera
			game:GetService("TweenService"):Create(camera, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FieldOfView = fov}):Play()
			
			game:GetService("TweenService"):Create(
				screenGui,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{Position = offScreenPosition}
			):Play()	
			EnablePlayerUI()

			rod.caughtGui.Parent.Background.Visible = true
			rod.caughtGui.Parent.CatchBar.Visible = true
			rod.caughtGui.Visible = false
			rod.paused = false
			rod.hooked = false
			rod.player.PlayerGui.FishingBar.Enabled = false
			rod.waitingForHook = false
		end



	end)

	local TweenService = game:GetService("TweenService")
	rod.currentBrainrot = RequestBrainrot:InvokeServer()
	
	local _rarityData = {
		Common = { avoidMult = 0.05, fakeout = 0.00, momentum = 0.95, jitter = 5 },
		Rare = { avoidMult = 0.20, fakeout = 0.03, momentum = 0.80, jitter = 20 },

		Epic = { avoidMult = 0.90, fakeout = 0.45, momentum = 0.30, jitter = 80 },
		Legendary = { avoidMult = 0.93, fakeout = 0.55, momentum = 0.25, jitter = 90 },
		Mythic = { avoidMult = 0.96, fakeout = 0.62, momentum = 0.20, jitter = 100 },
		["Brainrot God"] = { avoidMult = 0.98, fakeout = 0.70, momentum = 0.15, jitter = 120 },
		["Brainrot God (Lucky Box)"] = { avoidMult = 0.99, fakeout = 0.75, momentum = 0.10, jitter = 140 },
		Secret = { avoidMult = 1.00, fakeout = 0.85, momentum = 0.05, jitter = 160 }
	}


	local function safeRandom(a, b)
		a = math.floor(a)
		b = math.floor(b)
		if a > b then a, b = b, a end
		return math.random(a, b)
	end

	local lastDirection = 0

	local function getTargetX(fishX, dir, maxX, playerLeft, playerRight)
		-- 50% chance to check for player
		if math.random() < 0.5 then
			local moveDist = safeRandom(15, 60)
			local target = math.clamp(fishX + dir * moveDist, 0, maxX)

			if target + rod.fishArea.AbsoluteSize.X * 0.5 > playerLeft and target + rod.fishArea.AbsoluteSize.X * 0.5 < playerRight then
				-- sometimes go further, sometimes ignore
				if math.random() < 0.5 then
					target = math.clamp(target + dir * 50, 0, maxX)
				end
			end

			return target
		else
			-- dumb move
			return math.clamp(fishX + safeRandom(-50, 50), 0, maxX)
		end
	end

	task.spawn(function()
		while task.wait() do
			if rod.paused or not rod.hooked or not rod.player.PlayerGui.FishingBar.Enabled then
				continue
			end

			local speed = rod.currentBrainrot.moveSpeed or 1
			local fakeoutChance = 0.2 + (speed * 0.03)
			local momentumChance = 0.6

			local rarityAvoid = {
				Common = 0.20,
				Rare = 0.40,
				Epic = 0.70,
				Legendary = 0.82,
				Mythic = 0.90,
				["Brainrot God"] = 0.95,
				["Brainrot God (Lucky Box)"] = 0.97,
				Secret = 0.99
			}

			local base = rarityAvoid[rod.currentBrainrot.rarity] or 0.3
			local avoidanceChance = math.clamp(base + (speed * 0.12), 0.1, 0.995)

			local bgLeft = rod.background.AbsolutePosition.X
			local bgWidth = rod.background.AbsoluteSize.X
			local fishWidth = rod.fishArea.AbsoluteSize.X
			local maxX = bgWidth - fishWidth

			local fishX = rod.fishArea.AbsolutePosition.X - bgLeft
			local fishCenter = fishX + fishWidth * 0.5

			local playerLeft = rod.playerSelection.AbsolutePosition.X - bgLeft
			local playerSize = rod.playerSelection.AbsoluteSize.X
			local playerRight = playerLeft + playerSize
			local playerCenter = playerLeft + playerSize * 0.5

			local avoiding = math.random() < avoidanceChance
			local targetX

			-- stuck in corner
			if fishX < 5 then
				targetX = safeRandom(40, maxX)
				lastDirection = 1
			elseif fishX > maxX - 5 then
				targetX = safeRandom(0, maxX - 40)
				lastDirection = -1

				-- inside player
			elseif fishCenter > playerLeft and fishCenter < playerRight then
				if fishCenter < playerCenter then
					targetX = safeRandom(playerRight + 4, math.min(maxX, playerRight + 100))
					lastDirection = 1
				else
					targetX = safeRandom(math.max(0, playerLeft - 100), playerLeft - 4)
					lastDirection = -1
				end

				-- avoiding
			elseif avoiding then
				local dir
				if math.random() < momentumChance then
					dir = lastDirection ~= 0 and lastDirection or (math.random() < 0.5 and -1 or 1)
				else
					dir = math.random() < 0.5 and -1 or 1
				end

				if math.random() < fakeoutChance then
					dir = -dir
				end

				lastDirection = dir
				targetX = getTargetX(fishX, dir, maxX, playerLeft, playerRight)
			else
				-- neutral movement
				targetX = math.clamp(fishX + safeRandom(-50, 50), 0, maxX)
				lastDirection = (targetX - fishX) < 0 and -1 or 1
			end

			-- pause if moving through player
			local fishCenterNext = targetX + fishWidth * 0.5
			local crossesPlayer = (fishCenter < playerLeft and fishCenterNext > playerRight) or
				(fishCenter > playerRight and fishCenterNext < playerLeft)

			if crossesPlayer then
				local edgeTarget = fishCenter < playerLeft and (playerLeft - fishWidth) or (playerRight)
				local durationEdge = 0.2  -- small pause at player edge
				local tweenEdge = TweenService:Create(
					rod.fishArea,
					TweenInfo.new(durationEdge, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{ Position = UDim2.new(0, edgeTarget, rod.fishArea.Position.Y.Scale, rod.fishArea.Position.Y.Offset) }
				)
				tweenEdge:Play()
				tweenEdge.Completed:Wait()
			end

			-- smooth movement to final target
			local moveDistance = math.abs(targetX - fishX)
			local duration = math.clamp(moveDistance / (100 * speed), 0.3, 1.2)

			local tween = TweenService:Create(
				rod.fishArea,
				TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ Position = UDim2.new(0, targetX, rod.fishArea.Position.Y.Scale, rod.fishArea.Position.Y.Offset) }
			)
			tween:Play()
			tween.Completed:Wait()
		end
	end)










	UserInputService.InputBegan:Connect(function(input, gp)
		if not rod.equipped then return end
		if gp then return end

		if isPressInput(input) then
			if not rod.equipped or rod.waitingForHook or rod.hooked then return end

			isHolding = true
			castPower = 0
			increasing = true

			local chargeGui = rod.pole:FindFirstChild("ChargeGui")
			if chargeGui then
				local background = chargeGui:FindFirstChild("BackGround")
				if background then
					local charge = background:FindFirstChild("Charge")
					if charge then
						charge.Size = UDim2.new(1, 0, 0, 0)
						charge.Position = UDim2.new(0, 0, 1, 0)
						chargeGui.Enabled = true
					end
				end
			end

			task.spawn(function()
				while isHolding do
					if not rod.equipped then return end
					task.wait(0.05)

					local delta = powerSpeed * 0.05
					if increasing then
						castPower += delta
						if castPower >= maxPower then
							castPower = maxPower
							increasing = false
						end
					else
						castPower -= delta
						if castPower <= minPower then
							castPower = minPower
							increasing = true
						end
					end

					local chargeGui = rod.pole:FindFirstChild("ChargeGui")
					if chargeGui then
						local background = chargeGui:FindFirstChild("BackGround")
						if background then
							local charge = background:FindFirstChild("Charge")
							if charge then
								local normalizedPower = castPower / maxPower
								local inverted = 1 - normalizedPower

								local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
								local goal = {
									Size = UDim2.new(1, 0, normalizedPower, 0),
									Position = UDim2.new(0, 0, inverted, 0)
								}

								game:GetService("TweenService"):Create(charge, tweenInfo, goal):Play()
							end
						end
					end
				end

				local chargeGui = rod.pole:FindFirstChild("ChargeGui")
				if chargeGui then
					local background = chargeGui:FindFirstChild("BackGround")
					if background then
						local charge = background:FindFirstChild("Charge")
						if charge then
							charge.Position = UDim2.new(0, 0, 0.98, 0)
							chargeGui.Enabled = false
						end
					end
				end
			end)
		end
	end)


	UserInputService.InputEnded:Connect(function(input, gp)
		if not rod.equipped or gp then return end
		if not isPressInput(input) or not isHolding then return end
		isHolding = false
		performCast()
	end)





	return rod
end

FinalizeBobber.OnClientEvent:Connect(function(data)
		local bobber = workspace.Casts:FindFirstChild(game.Players.LocalPlayer.Name .. " bobber")
		local rope = workspace.Casts:FindFirstChild(game.Players.LocalPlayer.Name .. " rope")
		if bobber then
			bobber:Destroy()
		end
		if rope then
			rope:Destroy()
		end
end)

-- why are you here you dumb nigg-
return FishingModule

