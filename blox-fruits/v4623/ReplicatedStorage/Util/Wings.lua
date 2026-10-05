local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sound = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("Sound"))
local Debris = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("Debris"))
local IdMap = require(game.ReplicatedStorage.IdMap)
local SetParentOverrideWithColor = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("SetParentOverrideWithColor"))
local SyncColorsOnChange = require(game.ReplicatedStorage.Util.SyncColorsOnChange)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local SkinVFX = require(game.ReplicatedStorage.Util.SkinVFX)
local Wings = {}
Wings.__index = Wings

function Wings.Attach(data)
	local size = data.Size or 1
	return (setmetatable({
		Root = data.Root,
		Size = size,
		R15 = false,
		Permanent = data.Permanent,
		Type = data.Type
	}, {
		__index = Wings
	}))
end

function Wings:Activate(_, flag: boolean?)
	local parent = self.Root.Parent
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(parent)
	assert(playerFromCharacter, "bad player")
	local v = playerFromCharacter:FindFirstChild("DracoRaceVFXColors") and "DracoRaceVFXColors" or "DragonFruitVFXColor"
	local v2 = flag == true and "DragonFruitVFXColor" or v

	if self.Root:FindFirstChild("WingV2") and self.Root.WingV2:GetAttribute("Permanent") then
		local wingV2 = self.Root.WingV2
		self.Permanent = true
		self.LastSize = self.Size
		local _ = wingV2.RootPart.WingWeld
		self.WingsModel = wingV2
		local wings = {}
		local wingsFlame = {}
		local originalRatesByEmitter = {}

		for i = 1, 2 do
			local attachments = {}
			table.insert(attachments, wingV2.PrimaryPart["Attachment" .. i .. 1])
			table.insert(attachments, wingV2.PrimaryPart["Attachment" .. i .. 2])
			table.insert(wings, {
				Attachments = attachments,
				Trail = attachments[1].Trail1,
				Trail2 = attachments[1].Trail2,
				Trail3 = attachments[1].Trail3
			})
			local folder = wingV2.PrimaryPart["WingFlame" .. i]

			if i == 1 then
				wingsFlame.NewWingFlame = folder
			elseif i == 2 then
				wingsFlame.NewWingFlame2 = folder
			end

			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					originalRatesByEmitter[emitter] = emitter:GetAttribute("OriginalRate")
				end
			end
		end

		self.Wings = wings
		self.WingsFlame = wingsFlame
		self.FlameParticles = originalRatesByEmitter
		self.HumanoidRootPart = parent.HumanoidRootPart
		return self
	else
		local v3 = parent.HumanoidRootPart.Size.Y / 2
		local hrpSizeScale = parent.HumanoidRootPart:GetAttribute("HrpSizeScale")
		local v4 = math.max(v3 * math.max(hrpSizeScale and hrpSizeScale.Y or 1, 0.5), 1)

		if not ReplicatedStorage.Assets:FindFirstChild("Wings") then
			return self
		end

		local wingV2 = ReplicatedStorage.Assets.Wings.WingV2
		local trail = ReplicatedStorage.Assets.Wings.Trail
		local trail2 = ReplicatedStorage.Assets.Wings.Trail2
		local trail3 = ReplicatedStorage.Assets.Wings.Trail3
		local wingFlame = ReplicatedStorage.Assets.Wings.WingFlame
		local clone = wingV2:Clone()
		clone:SetAttribute("Permanent", self.Permanent)

		if self.Type == "DracoWings" then
			clone.RootPart:SetAttribute("TrueTransparency", 1)
		end

		clone:SetPrimaryPartCFrame(self.Root.CFrame)
		clone:ScaleTo(1.875 * v4)
		local motor6D = nil
		local connections = {}

		if self.Permanent then
			local v5 = v4

			local function onScale()
				v4 = parent.HumanoidRootPart.Size.Y / 2
				local hrpSizeScale2 = parent.HumanoidRootPart:GetAttribute("HrpSizeScale")
				v4 *= math.max(hrpSizeScale2 and hrpSizeScale2.Y or 1, 0.5)
				v4 = math.max(v4, 1)

				if v5 == v4 then
					return
				end

				task.spawn(function()
					clone:ScaleTo(1.875 * v4)
					motor6D.C1 = CFrame.new(0, -0.8250000000000001 * v4, -0.8250000000000001 * v4)
				end)
				v5 = v4
			end

			table.insert(connections, parent.HumanoidRootPart:GetPropertyChangedSignal("Size"):Connect(onScale))

			if parent:FindFirstChild("Humanoid") and parent:FindFirstChild("HeadScale") then
				table.insert(connections, parent.Humanoid.HeadScale.Changed:Connect(onScale))
			end

			local function syncMembrane()
				local upperTorso = parent:FindFirstChild("UpperTorso")

				if not upperTorso then
					return
				end

				for _, v6 in pairs({ clone:FindFirstChild("Cube.007"), clone:FindFirstChild("Cube.008") }) do
					v6.Transparency = upperTorso.Transparency
				end
			end

			table.insert(connections, parent.UpperTorso:GetPropertyChangedSignal("Transparency"):Connect(syncMembrane))
			syncMembrane()
			task.delay(2, syncMembrane)
		end

		local wings = {}
		local wingsFlame = {}
		local ratesByEmitter = {}

		for i = 1, 2 do
			local v7 = i == 1 and 1 or -1
			local attachments = {}

			for i2 = 1, 2 do
				local v9 = i2 == 1 and 0 or 1
				local attachment = Instance.new("Attachment")
				attachment.Name = "Attachment" .. i .. i2
				attachment.CFrame = CFrame.new(v7 * 2.5 * 1.65 - v9 * v7 * 2.5 * 0.25, 1.25, -0.3125)
				attachment.Parent = clone.PrimaryPart
				table.insert(attachments, attachment)
			end

			local clone2 = trail:Clone()
			clone2.Enabled = false
			clone2.Name = "Trail1"
			local attachment2 = attachments[1]
			local attachment3 = attachments[2]
			clone2.Attachment0 = attachment2
			clone2.Attachment1 = attachment3

			if self.Type == "DracoWings" then
				SetParentOverrideWithColor(clone2, attachments[1], playerFromCharacter, v2, true)
				SyncColorsOnChange(clone2, playerFromCharacter, v2)
			end

			local clone3 = trail2:Clone()
			clone3.Enabled = false
			clone3.Name = "Trail2"
			local attachment4 = attachments[1]
			local attachment5 = attachments[2]
			clone3.Attachment0 = attachment4
			clone3.Attachment1 = attachment5

			if self.Type == "DracoWings" then
				SetParentOverrideWithColor(clone3, attachments[1], playerFromCharacter, v2, true)
				SyncColorsOnChange(clone3, playerFromCharacter, v2)
			end

			local clone4 = trail3:Clone()
			clone4.Enabled = false
			clone4.Name = "Trail3"
			local attachment6 = attachments[1]
			local attachment7 = attachments[2]
			clone4.Attachment0 = attachment6
			clone4.Attachment1 = attachment7

			if self.Type == "DracoWings" then
				SetParentOverrideWithColor(clone4, attachments[1], playerFromCharacter, v2, true)
				SyncColorsOnChange(clone4, playerFromCharacter, v2)
			end

			table.insert(wings, {
				Attachments = attachments,
				Trail = clone2,
				Trail2 = clone3,
				Trail3 = clone4
			})
			local clone5 = wingFlame:Clone()
			clone5.Name = "WingFlame" .. i
			clone5.Weld.Part0 = clone.PrimaryPart

			if self.Type == "DracoWings" then
				clone5:SetAttribute("TrueTransparency", 1)
				SetParentOverrideWithColor(clone5, clone.PrimaryPart, playerFromCharacter, v2, true)
				SyncColorsOnChange(clone5, playerFromCharacter, v2)
			end

			if i == 1 then
				clone5.Weld.C0 = CFrame.new(3, 0, 0)
				wingsFlame.NewWingFlame = clone5
			elseif i == 2 then
				clone5.Weld.C0 = CFrame.new(-3, 0, 0)
				wingsFlame.NewWingFlame2 = clone5
			end

			for _, emitter in pairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:SetAttribute("OriginalRate", emitter.Rate)
				ratesByEmitter[emitter] = emitter.Rate
				emitter.Enabled = true
				emitter.Rate = 0
			end
		end

		self.LastSize = self.Size
		motor6D = Instance.new("Motor6D")
		motor6D.Name = "WingWeld"
		motor6D.Part0 = self.Root
		motor6D.Part1 = clone.RootPart
		motor6D.C1 = CFrame.new(0, -0.8250000000000001 * v4, -0.8250000000000001 * v4)
		motor6D.Parent = clone.RootPart
		clone.Parent = self.Root
		local v7 = nil
		local v8 = nil
		local v9 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function playAnim(currentAnimation)
			local child = self.WingsModel:FindFirstChild(currentAnimation)

			if child then
				if v8 then
					v8:Stop(0.5)
				end

				if self.markerConnection then
					self.markerConnection:Disconnect()
					self.markerConnection = nil
				end

				local v10 = v9[currentAnimation] or self.WingsModel.AnimationController:LoadAnimation(child)
				local currentAnimationSpeed = clone:GetAttribute("CurrentAnimationSpeed") or 1
				v10:Play(0.5, nil, currentAnimation == "Idle" and 0.8 or currentAnimationSpeed)

				if currentAnimation == "Flap" then
					local lastTime = tick()
					self.markerConnection = v10:GetMarkerReachedSignal("Wingflap"):Connect(function()
						local v11

						if tick() - lastTime < 0.25 then
							v11 = 1.5
						elseif tick() - lastTime < 0.45 then
							v11 = 1.25
						elseif tick() - lastTime > 1.1 then
							v11 = 0.85
						else
							v11 = 1
						end

						lastTime = tick()
						Sound:Play("BF_V3_WingFlaps_Mid_06", self.Root, nil, v11)
					end)
				elseif currentAnimation == "Jetpack" then
					local lastTime = tick()
					self.markerConnection = v10.DidLoop:Connect(function()
						local v11

						if tick() - lastTime < 0.25 then
							v11 = 1.5
						elseif tick() - lastTime < 0.45 then
							v11 = 1.25
						elseif tick() - lastTime > 1.1 then
							v11 = 0.85
						else
							v11 = 1
						end

						lastTime = tick()
						Sound:Play("BF_V3_WingFlaps_Mid_06", self.Root, nil, v11 * 1.1)
					end)
				end

				v8 = v10
				v9[currentAnimation] = v10
			end
		end

		clone:GetAttributeChangedSignal("CurrentAnimation"):Connect(function()
			local currentAnimation = clone:GetAttribute("CurrentAnimation")

			if currentAnimation == v7 then
				return
			end

			v7 = currentAnimation

			if currentAnimation then
				playAnim(currentAnimation)
				return
			end

			playAnim("Idle") -- equivalent call inferred; original call site unknown
		end)
		clone:GetAttributeChangedSignal("CurrentAnimationSpeed"):Connect(function()
			if v8 then
				v8:AdjustSpeed(clone:GetAttribute("CurrentAnimationSpeed") or 1)
			end
		end)
		self.WingsModel = clone
		self.Wings = wings
		self.WingsFlame = wingsFlame
		self.FlameParticles = ratesByEmitter
		self.Connections = connections
		self.HumanoidRootPart = parent.HumanoidRootPart

		if self.Type == "DracoWings" and playerFromCharacter then
			local v10 = nil

			local function applyWingSkin(p: number?)
				if not (playerFromCharacter and clone.Parent) then
					return
				end

				local modification = Modification.Data.Modification.fromItemReplication(playerFromCharacter)
				local adornee = Modification.Data.Adornee.fromItemReplication(playerFromCharacter)
				local dragonWestDragonWest = IdMap.Moveset["Dragon (West)-Dragon (West)"]
				local dragonEastDragonEast = IdMap.Moveset["Dragon (East)-Dragon (East)"]
				local dragonType = nil

				for _, tool in parent:GetChildren() do
					if not (tool:IsA("Tool") and tool:GetAttribute("DragonType") ~= nil) then
						continue
					end

					dragonType = tool:GetAttribute("DragonType")
					break
				end

				if dragonType ~= nil then
					v10 = dragonType
				end

				local v12 = dragonType or v10

				if not p then
					if v12 == nil then
						for _, v14 in { dragonWestDragonWest, dragonEastDragonEast } do
							local preferredModification = Modification.getPreferredModification(
								v14,
								"Skin",
								modification,
								adornee
							)

							if not preferredModification then
								continue
							end

							p = preferredModification
							break
						end

						p = p or Modification.matchDefaultSkin(dragonWestDragonWest):asNullable()
					else
						if v12 == "East" then
							dragonWestDragonWest = dragonEastDragonEast
						end

						p = Modification.getPreferredModification(dragonWestDragonWest, "Skin", modification, adornee) or Modification.matchDefaultSkin(dragonWestDragonWest):asNullable()
					end
				end

				if p then
					SkinVFX.applySkin(p, {
						[clone] = "Wings.DracoWings"
					})
				end
			end

			local itemIdChangedConnection = nil

			local function updateVFXFolder(instance)
				if itemIdChangedConnection then
					itemIdChangedConnection:Disconnect()
				end

				if not instance then
					applyWingSkin()
					return
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function updateFromAttr()
					local itemId = instance:GetAttribute("ItemId")

					if type(itemId) == "number" then
						applyWingSkin(itemId)
					else
						applyWingSkin()
					end
				end

				itemIdChangedConnection = instance:GetAttributeChangedSignal("ItemId"):Connect(function()
					updateFromAttr() -- equivalent call inferred; original call site unknown
				end)
				updateFromAttr() -- equivalent call inferred; original call site unknown
			end

			local childRemovedConnection = playerFromCharacter.ChildRemoved:Connect(function(child)
				if child.Name == v2 then
					updateVFXFolder(playerFromCharacter:FindFirstChild(v2))
				end
			end)
			local childAddedConnection = playerFromCharacter.ChildAdded:Connect(function(child)
				if child.Name == v2 then
					updateVFXFolder(child)
				end
			end)

			function self.SkinCleanup()
				if itemIdChangedConnection then
					itemIdChangedConnection:Disconnect()
				end

				childRemovedConnection:Disconnect()
				childAddedConnection:Disconnect()
			end

			updateVFXFolder(playerFromCharacter:FindFirstChild(v2))

			local function onDragonToolChanged(tool)
				if tool:IsA("Tool") and tool:GetAttribute("DragonType") ~= nil then
					applyWingSkin()
				end
			end

			table.insert(connections, parent.ChildAdded:Connect(onDragonToolChanged))
			table.insert(connections, parent.ChildRemoved:Connect(onDragonToolChanged))
			task.spawn(function()
				for i = 1, 6 do
					if not clone.Parent then
						break
					end

					updateVFXFolder(playerFromCharacter:FindFirstChild(v2))
					task.wait(i * 0.5)
				end
			end)
		end

		playAnim("Idle") -- equivalent call inferred; original call site unknown
		return self
	end
end

function Wings.SetAnim(p, currentAnimation, currentAnimationSpeed)
	p.WingsModel:SetAttribute("CurrentAnimationSpeed", currentAnimationSpeed)
	p.WingsModel:SetAttribute("CurrentAnimation", currentAnimation)
end

function Wings:SetRate(p2)
	local v = p2 < 0.1 and 0 or p2 > 1 and 1 or p2

	for k, flameParticle in pairs(self.FlameParticles) do
		k.Rate = flameParticle * v
	end
end

function Wings:SetTrailEnabled(enabled)
	for _, wing in pairs(self.Wings) do
		wing.Trail2.Enabled = enabled
		wing.Trail3.Enabled = enabled
	end
end

function Wings:Update(_, _)
	local v = self.HumanoidRootPart.Size.Y / 2

	for k, wing in next, self.Wings, nil do
		local attachments = wing.Attachments
		local v2 = k == 1 and 1 or -1
		local v3 = (self.Permanent and self.LastSize or self.Size) * 2.5 * v
		attachments[1].CFrame = CFrame.new(v2 * v3 * 1.8 - 0 * v2 * v3 * 1.15, v3 * 0.5, v3 * 0.025)
		attachments[2].CFrame = CFrame.new(v2 * v3 * 1.8 - 1 * v2 * v3 * 1.15, v3 * 0.5, v3 * 0.025)
	end

	if self.Permanent then
		return self
	end

	if self.LastSize ~= self.Size then
		self.LastSize = self.Size
		self.WingsModel:ScaleTo((math.max(0.01, self.Size * 2.5 * 0.75 * v)))
	end

	return self
end

function Wings:Destroy(p, p2)
	self:SetTrailEnabled(false)
	self:SetRate(0)

	if self.Permanent and not p2 then
		return
	end

	for _, connection in pairs(self.Connections) do
		connection:Disconnect()
	end

	if self.SkinCleanup then
		self.SkinCleanup()
		self.SkinCleanup = nil
	end

	local parent = self.Root.Parent
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(parent)
	local v = playerFromCharacter:FindFirstChild("DracoRaceVFXColors") and "DracoRaceVFXColors" or "DragonFruitVFXColor"

	for _, folder in pairs(self.WingsFlame) do
		folder.Weld.Enabled = false
		folder.Anchored = true

		if self.Type == "DracoWings" then
			if playerFromCharacter then
				SetParentOverrideWithColor(folder, workspace.Terrain, playerFromCharacter, v, true)
			else
				folder.Parent = workspace.Terrain
			end
		end

		Debris:AddItem(folder, 5)

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		if not p then
			continue
		end

		local clone = ReplicatedStorage.Assets.Wings.EndImpact:Clone()
		clone.CFrame = folder.CFrame

		if self.Type == "DracoWings" then
			clone:SetAttribute("TrueTransparency", 1)
			clone.StartImpact:SetAttribute("TrueTransparency", 1)

			if playerFromCharacter then
				SetParentOverrideWithColor(clone, folder, playerFromCharacter, v, true)
			else
				clone.Parent = folder
			end
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end

	for _, wing in next, self.Wings, nil do
		for _, attachment in next, wing.Attachments, nil do
			Debris:AddItem(attachment, 5)
			attachment.CFrame = CFrame.new(attachment.WorldPosition)

			if self.Type ~= "DracoWings" then
				continue
			end

			if playerFromCharacter then
				SetParentOverrideWithColor(attachment, workspace.Terrain, playerFromCharacter, v, true)
			else
				attachment.Parent = workspace.Terrain
			end
		end
	end

	self.WingsModel:Destroy()
end

return Wings