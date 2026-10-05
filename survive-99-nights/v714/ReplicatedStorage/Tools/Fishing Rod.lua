local createVector = vector.create
local FishingRod = {}
FishingRod.__index = FishingRod
FishingRod.Cooldown = 0.5
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local mouse = localPlayer:GetMouse()
local random = Random.new()
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local v = {
	Color = ColorSequence.new(Color3.fromRGB(255, 141, 1)),
	TimeScale = 0.35
}
local v2 = {
	Color = ColorSequence.new(Color3.fromRGB(132, 106, 94)),
	TimeScale = 0.35
}
local v3 = {
	{
		Speed = 0.5,
		ZoneSize = 0.33,
		Goal = 2,
		StartingProgress = 3
	},
	{
		Speed = 0.54,
		ZoneSize = 0.28,
		Goal = 3,
		StartingProgress = 3
	},
	{
		Speed = 0.78,
		ZoneSize = 0.12,
		Goal = 6,
		StartingProgress = 2
	},
	{
		Speed = 0.86,
		ZoneSize = 0.075,
		Goal = 10,
		StartingProgress = 1,
		GoalLostOnFail = 4
	},
	{
		Speed = 0.9,
		ZoneSize = 0.04,
		Goal = 12,
		StartingProgress = 1,
		GoalLostOnFail = 7
	}
}

function FishingRod.new(model, realModel)
	local self = setmetatable({}, FishingRod)
	self.Model = model
	self.RealModel = realModel
	self.LastCast = 0
	self.State = "Idle"
	self.CatchCount = 0
	self.LastPullTime = -5
	self.Debris = {}
	return self
end

function FishingRod:Pull()
	if self.AlreadyClickedThisPass then
		return
	end

	self.AlreadyClickedThisPass = true
	local fishingCatchFrame = Client.Interface.FishingCatchFrame

	local function flashSuccessBar()
		task.spawn(function()
			TweenService:Create(
				fishingCatchFrame.TimingBar.SuccessArea,
				TweenInfo.new(0.02, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				}
			):Play()
			task.spawn(function()
				wait(0.02)
				TweenService:Create(
					fishingCatchFrame.TimingBar.SuccessArea,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						BackgroundColor3 = Color3.fromRGB(0, 255, 0)
					}
				):Play()
			end)
		end)
	end

	local Y = fishingCatchFrame.TimingBar.SuccessArea.AbsolutePosition.Y
	local v4 = fishingCatchFrame.TimingBar.SuccessArea.AbsolutePosition.Y + fishingCatchFrame.TimingBar.SuccessArea.AbsoluteSize.Y
	local Y2 = fishingCatchFrame.TimingBar.Bar.AbsolutePosition.Y
	local v5 = fishingCatchFrame.TimingBar.Bar.AbsolutePosition.Y + fishingCatchFrame.TimingBar.Bar.AbsoluteSize.Y
	local v6 = Y < v5 and Y2 < Y or Y2 < v4 and v4 < v5 or (Y < Y2 and v5 < v4 or false)

	if v6 then
		self.CatchProgress += 1
		Client.Sound.Play("FishHitMarker")
		task.spawn(function()
			TweenService:Create(
				fishingCatchFrame.TimingBar.SuccessArea,
				TweenInfo.new(0.02, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				}
			):Play()
			task.spawn(function()
				wait(0.02)
				TweenService:Create(
					fishingCatchFrame.TimingBar.SuccessArea,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						BackgroundColor3 = Color3.fromRGB(0, 255, 0)
					}
				):Play()
			end)
		end)
	else
		Client.Sound.Play("FishingMissedMarker")
		self.CatchProgress -= self.GoalLostOnFail or 1
	end

	if self.CatchProgress >= self.CatchGoal then
		self.ItemCaught = true
		Client.Events.ConfirmCatchItem:FireServer()
		Client.Sound.Play("FishCatch", {
			Volume = 0.5,
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.4
			}
		})
		self:Reel()
	elseif self.CatchProgress <= 0 then
		self.ItemCaught = nil
		self:Reel()
	else
		if v6 then
			self.LastPullTime = time()
			Client.Events.PlayAnimation:Fire("Rod_Reel", {
				Speed = 2
			})
			Client.FirstPersonModule.PlayAnimation("Rod_Reel", nil, 4, 2)
		elseif not v6 then
			Client.Events.PlayAnimation:Fire("Rod_FailReel", {
				Speed = 1
			})
			Client.FirstPersonModule.PlayAnimation("Rod_FailReel", nil, 4, 1)
		end

		local v7 = self.CatchProgress / self.CatchGoal
		fishingCatchFrame.SuccessBar.Bar.Size = UDim2.new(1, 0, v7, 0)
		fishingCatchFrame.SuccessBar.Bar.BackgroundColor3 = GetProgressBarColour(v7)
	end
end

function FishingRod:StartCatchTimer(p, p2)
	self.CatchCount += 1
	local ropeConstraint = self.Model.RopeAttach.RopeConstraint
	local _ = self.Hook
	task.spawn(function()
		local v4 = Client.Events.StartCatchTimer:InvokeServer(self.RealModel, p, p2)

		if v4 and v4.Item and self.State == "Fishing" and self.Equipped then
			Client.Events.PlayAnimation:Fire("Rod_FishHooked", {
				Speed = 0.4
			})
			Client.Sound.Play("FishBite", {
				Volume = 0.5,
				Replicate = true,
				ReplicationProperties = {
					Instance = localPlayer.Character.Head,
					Volume = 0.4
				}
			})
			self.HookedItem = v4.Item
			local _ = ropeConstraint.Length
			local v5 = ropeConstraint.Length / ropeConstraint.CurrentDistance

			if v5 > 1 then
				local tweenModule = Client.TweenModule.new(function(p3)
					ropeConstraint.Length = ropeConstraint.CurrentDistance * (v5 - (v5 - 1) * p3)
				end, 0.15)
				tweenModule:BindToComplete(function()
					ropeConstraint.Length = 3
				end)
				tweenModule:Play()
			else
				ropeConstraint.Length = 3
			end

			local v6 = v3[v4.Difficulty]
			local startingProgress = v6.StartingProgress or 3
			self.CatchProgress = startingProgress
			self.CatchGoal = v6.Goal + startingProgress
			self.GoalLostOnFail = v6.GoalLostOnFail or 1
			self.AlreadyClickedThisPass = false
			local fishingCatchFrame = Client.Interface.FishingCatchFrame
			local total = 0
			local speed = v6.Speed
			local v7 = self.CatchProgress / self.CatchGoal
			fishingCatchFrame.SuccessBar.Bar.Size = UDim2.new(1, 0, v7, 0)
			fishingCatchFrame.SuccessBar.Bar.BackgroundColor3 = GetProgressBarColour(v7)
			fishingCatchFrame.TimingBar.SuccessArea.Size = UDim2.new(1, 0, v6.ZoneSize, 0)
			local v9 = random:NextInteger(15, (1 - v6.ZoneSize - 0.3) * 100) / 100
			fishingCatchFrame.TimingBar.SuccessArea.Position = UDim2.new(0.5, 0, v9, 0)
			local v10 = 0.1
			local platform = Client.Utility.GetPlatform()

			if platform == "Mobile" then
				fishingCatchFrame.Size = UDim2.new(0.18, 0, 0.8, 0)
			end

			local function update(p3)
				if platform == "Mobile" then
					p3 *= 0.85
				end

				total += p3
				local v11 = (math.sin(total * 3.141592653589793 * 2 * speed) / 2 + 0.5) * 0.9 + 0.05
				local v12 = math.cos(total * 3.141592653589793 * 2 * speed) * 0.45

				if math.sign(v12) ~= math.sign(v10) then
					self.AlreadyClickedThisPass = false
				end

				v10 = v12
				fishingCatchFrame.TimingBar.Bar.Position = UDim2.new(0.5, 0, v11, 0)
			end

			RunService:BindToRenderStep("FishingCatchMinigame", Enum.RenderPriority.First.Value, update)
			update(0)
			fishingCatchFrame.Visible = true
		end
	end)
end

function GetProgressBarColour(p)
	return (Color3.fromHSV(70 * p / 255, 1, 1))
end

function FishingRod:StartFishingAtLocation(p, p2)
	self.State = "Fishing"
	local model = self.Model
	local ropeConstraint = model.RopeAttach.RopeConstraint
	local attachment = model.RopeAttach.Attachment
	local hook = self.Hook
	local pivot = hook:GetPivot()
	local Y = p.Position.Y
	self.FishingInLava = p.Instance:GetAttribute("IsLava")
	self.FishingInChocolate = p.Instance:GetAttribute("ChocolateWater")
	Client.GuiButtonHandler.ShowButton("Reel")
	local unit = (attachment.WorldCFrame.Position - p2.Position).Unit
	local _ = p2 + unit * math.clamp((Y - p2.Y) / unit.Y, 0, 2)
	Client.Events.PlayerRodBobbleInWater:FireOtherClients(p2)
	local v4 = self.FishingInLava and v or self.FishingInChocolate and v2
	Client.Utility.SpawnParticles("Splash_Cast", p2, v4)
	local v5 = Client.PlayerHandler.HumanoidRootPart.Position + createVector(0, 3, 0)
	local v6 = math.clamp(((v5 - p2.Position) * createVector(1, 0, 1)).Magnitude + 10, 10, 100)
	local v7 = math.clamp(((v5 - p2.Position) * createVector(1, 0, 1)).Magnitude / v6, 0, 1)
	ropeConstraint.Length = ropeConstraint.CurrentDistance + (1 - v7) * 2
	task.spawn(function()
		while self.Equipped and self.State == "Fishing" do
			task.wait()
			local v8 = Client.PlayerHandler.HumanoidRootPart.Position + createVector(0, 3, 0)
			local magnitude = ((v8 + Vector3.new(0, 25 - v8.Y, 0) - p2.Position) * createVector(1, 0, 1)).Magnitude

			if (pivot.Position - p2.Position).Magnitude > 0.01 then
				local lerped = pivot:Lerp(p2, 0.05)
				pivot = lerped
				hook:PivotTo(lerped)
			end

			if v6 + 0.01 < magnitude then
				print("too far")
				self:Reel()
			end

			if self.HookedItem then
				continue
			end

			local v9 = math.clamp(magnitude / v6, 0, 1)
			ropeConstraint.Length = ropeConstraint.CurrentDistance + (1 - v9) * 2
		end
	end)
	task.spawn(function()
		while self.Equipped and self.State == "Fishing" do
			local v8 = random:NextInteger(15, 35) / 10
			local total = 0

			repeat
				total += task.wait(0.1)
			until (self.HookedItem and v8 * 0.3 or v8) <= total or not self.Equipped or self.State ~= "Fishing"

			if not (self.Equipped and self.State == "Fishing") then
				continue
			end

			local v9 = self.FishingInLava and v or self.FishingInChocolate and v2
			Client.Utility.SpawnParticles("Splash_Fishing", p2, v9)
		end
	end)
	self:StartCatchTimer(p.Instance, p2.Position)
end

Client.Events.PlayerCastRod:Connect(function(player, list)
	if player and player.Character then
		local toolHandle = player.Character:FindFirstChild("ToolHandle")

		if toolHandle then
			for _, child in pairs(toolHandle:GetChildren()) do
				if child.Name == "NewBobber" then
					child:Destroy()
				end
			end
		end

		if toolHandle and toolHandle:FindFirstChild("Bobber") then
			local clone = toolHandle.Bobber:Clone()

			for _, part in pairs(clone:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "BobberMain" then
					part.Transparency = 0
				end
			end

			clone.Name = "NewBobber"
			clone.BobberMain.WeldConstraint:Destroy()
			clone.Parent = toolHandle
			local ropeConstraint = toolHandle.RopeAttach.RopeConstraint
			ropeConstraint.Attachment1 = clone.BobberMain.RopeAttachment

			for _, part in pairs(toolHandle.Bobber:GetChildren()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end

			local raycastParams2 = RaycastParams.new()
			raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams2.FilterDescendantsInstances = {
				workspace.Items,
				workspace.Particles,
				workspace.Map.Blockers,
				player.Character
			}
			print(list)
			local v4, v5, v6, v7 = unpack(list)
			local v8 = false
			local v9 = nil
			task.spawn(function()
				while clone.Parent and toolHandle.Parent do
					local v10 = task.wait()

					if clone.Parent == nil or clone:GetAttribute("Reeling") then
						return
					end

					v6 += v7 * v10
					local v11 = v5 + v6 * v10

					if not v8 then
						v8 = true
						v11 = v5 + v6.Unit * 1
					end

					v9 = Client.CollisionUtility.GetProjectileHit(v5, v11, raycastParams2)

					if v9 then
						break
					end

					v5 = v11
					local v12 = v4 + v5 - v6.Unit * 1
					clone:PivotTo(v12)
					local v13 = Client.PlayerHandler.HumanoidRootPart.Position + createVector(0, 3, 0)
					local v14 = math.clamp(((v13 - v12.Position) * createVector(1, 0, 1)).Magnitude + 10, 10, 100)
					local v15 = math.clamp(((v13 - v12.Position) * createVector(1, 0, 1)).Magnitude / v14, 0, 1)
					ropeConstraint.Length = ropeConstraint.CurrentDistance + (1 - v15) * 2
				end

				if v9 then
					clone:Destroy()
				end
			end)
		end
	end
end)
Client.Events.PlayerRodBobbleInWater:Connect(function(player, cframe)
	if player and player.Character then
		local toolHandle = player.Character:FindFirstChild("ToolHandle")

		if toolHandle and toolHandle:FindFirstChild("Bobber") then
			local clone = toolHandle.Bobber:Clone()

			for _, part in pairs(clone:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "BobberMain" then
					part.Transparency = 0
				end
			end

			clone.Name = "NewBobber"
			clone.BobberMain.WeldConstraint:Destroy()
			clone:PivotTo(cframe)
			clone.Parent = toolHandle
			local ropeConstraint = toolHandle.RopeAttach.RopeConstraint
			ropeConstraint.Attachment1 = clone.BobberMain.RopeAttachment
			ropeConstraint.Length = 0

			for _, part in pairs(toolHandle.Bobber:GetChildren()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end
		end
	end
end)
Client.Events.PlayerRodReset:Connect(function(player, p)
	if player and player.Character then
		local toolHandle = player.Character:FindFirstChild("ToolHandle")

		if toolHandle and toolHandle:FindFirstChild("NewBobber") and toolHandle:FindFirstChild("Bobber") then
			if p then
				toolHandle.RopeAttach.RopeConstraint.Length = 0
				local newBobber = toolHandle.NewBobber
				local pivot = newBobber:GetPivot()
				local bobber = toolHandle.Bobber
				newBobber:SetAttribute("Reeling", true)
				Client.TweenModule.new(function(p2)
					if not (newBobber and newBobber.Parent and bobber.Parent) then
						return true
					end

					newBobber:PivotTo((pivot:Lerp(bobber:GetPivot(), p2)))
				end, 0.65, "Quad"):Play()
				task.wait(0.65)

				if not (newBobber.Parent and bobber.Parent) then
					return
				end
			end

			for _, child in pairs(toolHandle:GetChildren()) do
				if child.Name == "NewBobber" then
					child:Destroy()
				end
			end

			if toolHandle:FindFirstChild("Bobber") then
				local ropeConstraint = toolHandle.RopeAttach.RopeConstraint
				ropeConstraint.Attachment1 = toolHandle.Bobber.BobberMain.RopeAttachment
				ropeConstraint.Length = 0

				for _, part in pairs(toolHandle.Bobber:GetChildren()) do
					if part:IsA("BasePart") and part.Name ~= "BobberMain" then
						part.Transparency = 0
					end
				end
			end
		end
	end
end)

function FishingRod:Cast()
	print("Cast rod")
	self.ItemHooked = nil
	self.ItemCaught = nil
	self.HookedItem = nil
	Client.Sound.Play("FishCast", {
		Volume = 0.5,
		Replicate = true,
		ReplicationProperties = {
			Instance = localPlayer.Character.Head,
			Volume = 0.4
		}
	})
	local v4 = localPlayer:GetAttribute("Class") == "Fisherman" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 2
	local v5 = Client.Utility.HasTalent(localPlayer, "FishingRodIncreaseCast") and true or v4

	if v5 then
		Client.Events.PlayAnimation:Fire("Rod_Cast", {
			Speed = 4
		})
		Client.FirstPersonModule.PlayAnimation("Rod_Cast", nil, 4, 4)
		task.wait(0.05)
	else
		Client.Events.PlayAnimation:Fire("Rod_Cast")
		Client.FirstPersonModule.PlayAnimation("Rod_Cast", nil, 4)
		task.wait(0.45)
	end

	if not self.Equipped then
		return
	end

	self.State = "Casting"
	local model = self.Model
	local bobber = model.Bobber
	local pivot = bobber:GetPivot()

	if Client.FirstPersonModule.IsVisible() then
		local tool = Client.FirstPersonModule.GetTool()

		if tool then
			pivot = tool.Bobber:GetPivot()
		end
	end

	local position = pivot.Position
	local v6 = (mouse.Hit.Position - pivot.Position).Unit * (v5 and 70 or 50) + createVector(0, 10, 0)
	local clone = bobber:Clone()

	for _, part in pairs(bobber:GetChildren()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end

	local tool = Client.FirstPersonModule.GetTool()

	if tool then
		for _, part in pairs(tool.Bobber:GetChildren()) do
			if part:IsA("BasePart") then
				part.Transparency = 1
			end
		end
	end

	for _, part in pairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		if part.Name ~= "BobberMain" then
			part.Transparency = 0
		end

		part.CanCollide = false
		part.Anchored = true
	end

	clone.PrimaryPart.WeldConstraint:Destroy()
	self.Hook = clone
	clone.Parent = workspace.Particles
	local ropeConstraint = model.RopeAttach.RopeConstraint
	local v7 = nil
	local v8 = pivot - pivot.Position
	local v9 = false
	local v10 = {
		v8,
		position,
		v6,
		createVector(0, -60, 0)
	}
	Client.Events.PlayerCastRod:FireOtherClients(v10)
	task.spawn(function()
		while self.Equipped and self.State == "Casting" do
			local v11 = task.wait()
			v6 += createVector(0, -60, 0) * v11
			local v12 = position + v6 * v11

			if not v9 then
				v9 = true
				v12 = position + v6.Unit * 1
			end

			v7 = Client.CollisionUtility.GetProjectileHit(position, v12, raycastParams)

			if v7 then
				break
			end

			position = v12
			local v13 = v8 + position - v6.Unit * 1
			clone:PivotTo(v13)
			local v14 = Client.PlayerHandler.HumanoidRootPart.Position + createVector(0, 3, 0)
			local v15 = math.clamp(((v14 - v13.Position) * createVector(1, 0, 1)).Magnitude + 10, 10, 100)
			local v16 = math.clamp(((v14 - v13.Position) * createVector(1, 0, 1)).Magnitude / v15, 0, 1)
			ropeConstraint.Length = ropeConstraint.CurrentDistance + (1 - v16) * 2
		end

		if not self.Equipped then
			return
		end

		if v7 then
			if v7.Instance:HasTag("Water") then
				Client.Sound.Play("FishBobber")
				local v11 = CFrame.new(v7.Position) + createVector(0, 0, 0)
				self:StartFishingAtLocation(v7, v11)
			else
				print("collision with land")

				for _, part in pairs(clone:GetChildren()) do
					if not part:IsA("BasePart") then
						continue
					end

					part.CanCollide = part.Name == "BobberMain" or part.Name == "Hook"
					part.Anchored = false
				end

				clone.PrimaryPart.CanTouch = true
				clone.PrimaryPart.CanQuery = true
				ropeConstraint.Attachment1 = clone.PrimaryPart.RopeAttachment
				local _ = v7.Instance.Parent
				clone.PrimaryPart.Touched:Connect(function(otherPart)
					if otherPart:HasTag("Water") then
						self:Reel()
					end
				end)
				local v11 = math.max(ropeConstraint.Length, 1)
				task.spawn(function()
					while self.Equipped and self.State == "Casting" and clone.Parent ~= nil do
						ropeConstraint.Length = math.clamp(ropeConstraint.CurrentDistance * 1.05, 1, v11)
						task.wait()
					end
				end)
			end
		end
	end)
end

function FishingRod:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function FishingRod:CleanUp()
	for _, v4 in pairs(self.Debris) do
		if v4.Name == "FishingParticles" then
			local v5 = v4
			task.delay(3, function()
				v5:Destroy()
			end)
		else
			v4:Destroy()
		end
	end

	self.Debris = {}
	Client.GuiButtonHandler.HideButton("Reel")
end

function FishingRod:Reel()
	if self.State == "Casting" or self.State == "Fishing" then
		self.State = "Reeling"
		Client.GuiButtonHandler.HideButton("Reel")
		Client.Events.PlayerRodReset:FireOtherClients(true)

		if not self.ItemCaught then
			Client.Events.EndCatching:FireServer()
		end

		Client.Events.StopAnimation:Fire("Rod_FishHooked")
		Client.Interface.FishingCatchFrame.Visible = false
		RunService:UnbindFromRenderStep("FishingCatchMinigame")
		local pivot = self.Hook:GetPivot()
		self.ReelOrigin = pivot
		self.ReelPercent = 0

		if self.ItemCaught then
			local v4 = self.FishingInLava and v or self.FishingInChocolate and v2

			if self.HookedItem and self.HookedItem:GetAttribute("BigCatch") then
				Client.Utility.SpawnParticles("Splash_CatchBig", pivot, v4)
			else
				Client.Utility.SpawnParticles("Splash_Catch", pivot, v4)
			end
		end

		self.Model.RopeAttach.RopeConstraint.Attachment1 = self.FakeAttachHook
		local tweenModule = Client.TweenModule.new(function(reelPercent)
			self.ReelPercent = reelPercent
		end, 0.65, "Quad")
		tweenModule:BindToComplete(function()
			self.State = "Idle"
			self.LastCast = time()
			self:ResetHook()
			self:CleanUp()
		end)
		tweenModule:Play()
		Client.Sound.Play("FishReel", {
			Volume = 0.55,
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.3
			}
		})
		Client.Events.PlayAnimation:Fire("Rod_Reel", {
			Speed = 2
		})
		Client.FirstPersonModule.PlayAnimation("Rod_Reel", nil, 4, 2)
	end
end

function FishingRod:ResetHook()
	local model = self.Model
	local bobber = model.Bobber

	for _, part in pairs(bobber:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "BobberMain" then
			part.Transparency = 0
		end
	end

	local tool = Client.FirstPersonModule.GetTool()

	if tool then
		for _, part in pairs(tool.Bobber:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "BobberMain" then
				part.Transparency = 0
			end
		end
	end

	model.RopeAttach.RopeConstraint.Length = 0

	if self.Hook then
		self.Hook:Destroy()
		self.Hook = nil
	end

	Client.Events.PlayerRodReset:FireOtherClients()
end

function FishingRod:Activate()
	if self.State == "Idle" then
		if time() < self.LastCast + self.Cooldown then
			return
		end

		self.LastCast = time()
		self:Cast()
	elseif self.State == "Casting" then
		if time() < self.LastCast + self.Cooldown then
			return
		end

		self.LastCast = time()
		self:Reel()
	elseif self.State == "Fishing" then
		if self.HookedItem then
			self:Pull()
			return
		end

		if time() < self.LastCast + self.Cooldown then
			return
		end

		self.LastCast = time()
		self:Reel()
	end
end

function FishingRod.Deactivate(_) end

function FishingRod:UpdateHook()
	task.spawn(function()
		local model = self.Model
		local ropeConstraint = model.RopeAttach.RopeConstraint
		local attachment = model.RopeAttach.Attachment
		local bobber = model.Bobber
		local ropeAttachment = bobber.PrimaryPart.RopeAttachment
		local attachment2 = Instance.new("Attachment")
		attachment2.WorldCFrame = attachment.WorldCFrame
		attachment2.Parent = workspace.Terrain
		local attachment3 = Instance.new("Attachment")
		attachment3.WorldCFrame = attachment.WorldCFrame
		attachment3.Parent = workspace.Terrain
		self.FakeAttachHook = attachment3
		ropeConstraint.Attachment0 = attachment2
		ropeConstraint.Attachment1 = attachment3
		local attachment4 = nil
		local v4 = nil

		while self.Equipped do
			if attachment4 == nil then
				v4 = Client.FirstPersonModule.GetTool()

				if v4 then
					attachment4 = v4.RopeAttach.Attachment
				end
			end

			if self.State == "Reeling" and self.Hook ~= nil then
				local pivot = bobber:GetPivot()

				if Client.FirstPersonModule.IsVisible() and v4 ~= nil then
					pivot = v4.Bobber:GetPivot()
				end

				ropeConstraint.Length = 0
				local lerped = self.ReelOrigin:Lerp(pivot, self.ReelPercent or 0)
				self.Hook:PivotTo(lerped)

				if self.HookedItem and self.ItemCaught then
					local hookedItem = self.HookedItem
					hookedItem:PivotTo(lerped)
					hookedItem.Parent = workspace.Items
				end
			end

			if self.HookedItem and self.ItemCaught then
				local hookedItem = self.HookedItem
				local humanoidRootPart = Client.PlayerHandler.HumanoidRootPart
				local position = humanoidRootPart.Position

				if (position - hookedItem:GetPivot().Position).Magnitude <= 12 or self.State == "Idle" then
					self.HookedItem = nil
					self.ItemCaught = nil
					local assemblyLinearVelocity = humanoidRootPart.Velocity + createVector(0, 20, 0) + (position - hookedItem:GetPivot().Position).Unit * 40
					hookedItem.PrimaryPart.AssemblyLinearVelocity = assemblyLinearVelocity
				end
			end

			if Client.FirstPersonModule.IsVisible() and attachment4 ~= nil then
				attachment2.WorldCFrame = attachment4.WorldCFrame
			else
				attachment2.WorldCFrame = attachment.WorldCFrame
			end

			if self.Hook and self.Hook.PrimaryPart then
				attachment3.WorldCFrame = self.Hook.PrimaryPart.RopeAttachment.WorldCFrame
			elseif Client.FirstPersonModule.IsVisible() and v4 ~= nil then
				attachment3.WorldCFrame = v4.Bobber.PrimaryPart.RopeAttachment.WorldCFrame
			else
				attachment3.WorldCFrame = ropeAttachment.WorldCFrame
			end

			task.wait()
		end

		attachment2:Destroy()
		attachment3:Destroy()
	end)
end

function FishingRod:ToggleLevelParticles(levelParticlesOn)
	self.LevelParticlesOn = levelParticlesOn

	for _, emitter in pairs(self.Model:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") and emitter.Name == "UpgradeParticles" then
			emitter.Enabled = levelParticlesOn and emitter.Parent.Name ~= "CenterEmitPoint"
		end
	end

	local folder = Client.FirstPersonModule.IsVisible() and Client.FirstPersonModule.GetTool()

	if folder then
		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter.Name == "UpgradeParticles" then
				emitter.Enabled = levelParticlesOn and emitter.Parent.Name ~= "CenterEmitPoint"
			end
		end
	end
end

function FishingRod:FlashLevelParticles()
	if not self.LevelParticlesOn then
		return
	end

	local function emit(folder)
		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter.Name == "UpgradeParticles" and emitter.Parent.Name == "CenterEmitPoint" then
				emitter:Emit(1)
			end
		end
	end

	emit(self.Model)
	local tool = Client.FirstPersonModule.GetTool()

	if tool and Client.FirstPersonModule.IsVisible() then
		emit(tool)
	end
end

function FishingRod:TrackLevelUp()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		local XP = self.RealModel:GetAttribute("XP")
		local levelUpXP = self.RealModel:GetAttribute("LevelUpXP")

		if XP and levelUpXP and levelUpXP <= XP then
			self:ToggleLevelParticles(true)
		else
			self:ToggleLevelParticles(false)
		end
	end

	self.XPEvent = self.RealModel:GetAttributeChangedSignal("XP"):Connect(update)
	self.FlashEvent = Client.Events.ToolUpgradeFlash:Connect(function()
		self:FlashLevelParticles()
	end)
	update() -- equivalent call inferred; original call site unknown
end

function FishingRod:OnEquip()
	self.Equipped = true
	raycastParams.FilterDescendantsInstances = {
		workspace.Items,
		workspace.Particles,
		workspace.Map.Blockers,
		localPlayer.Character
	}
	self:UpdateHook()
	self:TrackLevelUp()
end

function FishingRod:OnUnequip()
	self.Equipped = false
	Client.Events.EndCatching:FireServer()
	Client.FirstPersonModule.StopAnimation("PullingRod")
	Client.Events.StopAnimation:Fire("Rod_FishHooked")
	Client.Interface.FishingCatchFrame.Visible = false
	RunService:UnbindFromRenderStep("FishingCatchMinigame")
	Client.GuiButtonHandler.HideButton("Reel")
	self:ResetHook()
	self:CleanUp()

	if self.XPEvent then
		self.XPEvent:Disconnect()
		self.XPEvent = nil
		self.FlashEvent:Disconnect()
	end
end

return FishingRod