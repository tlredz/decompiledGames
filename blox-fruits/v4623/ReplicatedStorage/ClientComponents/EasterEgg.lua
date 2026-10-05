local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Component = require(game.ReplicatedStorage.Modules.Component)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local Groups = require(game.ReplicatedStorage.Util.Sound.Groups)
local EasterNetwork = require(game.ReplicatedStorage.Controllers.UI.EasterCodex.EasterNetwork)
local EasterEggs = require(game.ReplicatedStorage.Modules.Data.EasterEggs)
local Effect = require(game.ReplicatedStorage.Effect)
local BobInWater = require(script.BobInWater)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "EasterEgg26",
	Ancestors = { workspace }
})

function v:Construct()
	self._CFrame = assert(self.Instance:GetAttribute("CFrame"))
	self._SpawnCF = self._CFrame
	self._UID = assert(self.Instance:GetAttribute("UID"))
	self._LastPlayedPoofFX = 1
	self.EggName = self.Instance:GetAttribute("EggName")
	self.PrimaryPart = nil
	self.Maid = Trove.new()
	self.State = EasterNetwork.Streaming[self._UID].State
end

function v:Xray()
	local eggXRay = localPlayer:GetAttribute("EggXRay")
	local _xray = self.Egg:FindFirstChild("_xray")

	if eggXRay then
		if _xray then
			_xray.Enabled = true
			return
		end

		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "_xray"
		local frame = Instance.new("Frame", billboardGui)
		billboardGui.Size = UDim2.fromScale(3, 3)
		billboardGui.AlwaysOnTop = true
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		billboardGui.Parent = self.Egg
		billboardGui.Adornee = self.PrimaryPart
	elseif not eggXRay and _xray then
		_xray.Enabled = false
	end
end

function v:PlayPoofFX(value: number?, vector2: Vector3?)
	if tick() - self._LastPlayedPoofFX >= 1 then
		self._LastPlayedPoofFX = tick()
		local v2 = vector2 or self._CFrame.Position
		local magnitude = (workspace.CurrentCamera.CFrame.Position - v2).Magnitude

		if magnitude <= (value or 1e999) then
			local worldToScreenPoint, v3 = workspace.CurrentCamera:WorldToScreenPoint(v2)

			if magnitude <= 300 or v3 and worldToScreenPoint.Z > 0 then
				Effect.new("Chests.Despawn"):play({
					CFrame = CFrame.new(v2)
				})
			end
		end
	end
end

function v:ConnectTouched()
	if not self._TouchConnected then
		self._TouchConnected = true
		local v2 = {}
		self.Maid:Add(self.PrimaryPart.Touched:Connect(function(otherPart)
			if v2[otherPart] then
				return
			end

			v2[otherPart] = true
			task.delay(0.5, function()
				v2[otherPart] = nil
			end)
			local parent = otherPart.Parent

			if parent then
				local Players2 = game:GetService("Players")
				parent = Players2:GetPlayerFromCharacter(parent)
			end

			if parent then
				EasterNetwork.TryCollectEgg(self._UID, {
					MendedSide = self.MendedSide
				})
			end
		end))
	end
end

function v:ApplyIdleFX()
	task.spawn(function()
		if not self._IdleFxApplied then
			self._IdleFxApplied = true
			local v2 = EasterEggs.List[self.EggName]
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local chestModels = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ChestModels", 10)
			local mirageChest = nil

			if v2.Rarity ~= "Common" and v2.Rarity ~= "Uncommon" then
				if v2.Rarity == "Rare" then
					mirageChest = chestModels:WaitForChild("MirageChest", 5)
				elseif v2.Rarity == "Legendary" then
					mirageChest = chestModels:WaitForChild("DiamondChest", 5)
				elseif v2.Rarity == "Mythical" then
					mirageChest = chestModels:WaitForChild("GoldChest", 5)
				end
			end

			local lootTexture = mirageChest and mirageChest:FindFirstChild("LootTexture")

			if lootTexture then
				for _, child in pairs(lootTexture:GetChildren()) do
					if not (child.Name == "Dots" or child.Name == "Twinkle") then
						continue
					end

					local clone = child:Clone()
					clone.Parent = self.Egg.PrimaryPart
				end
			end
		end
	end)
end

function v:SpawnEgg()
	local eggName = self.Instance:GetAttribute("EggName")
	local egg = self.Maid:Add(assert(script.EggModels:FindFirstChild(eggName), (`{eggName} is missing`)):Clone())
	self.Maid:Add(function()
		egg:Destroy()
	end)
	task.spawn(function()
		if eggName == "Sealed Showdown Egg" then
			for _, part in pairs(egg:GetChildren()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end
		elseif eggName == "Mended Egg" then
			local v3 = nil
			local Players2 = game:GetService("Players")
			local localPlayer2 = Players2.LocalPlayer
			local character = localPlayer2.Character

			local function update()
				local mendedEgg = localPlayer2.Backpack:FindFirstChild("Mended Egg") or character and character:FindFirstChild("Mended Egg")
				local v4 = math.random(1, 2) == 1
				local v5

				if mendedEgg then
					local left = mendedEgg:GetAttribute("Left") == true
					local _ = mendedEgg:GetAttribute("Right") == true

					if left then
						v4 = false
						v5 = true
					else
						v4 = true
						v5 = false
					end
				else
					v5 = not v4
				end

				v3 = mendedEgg
				self.MendedSide = v4 and "Left" or "Right"

				for _, part in pairs(egg:GetChildren()) do
					if not part:IsA("BasePart") then
						continue
					end

					if part.Name:match("Right") then
						part.Transparency = v5 and 0 or 1
					elseif part.Name:match("Left") then
						part.Transparency = v4 and 0 or 1
					end
				end
			end

			local function characterAdded(instance)
				self.Maid:Add(instance.ChildAdded:Connect(function(tool)
					if tool:IsA("Tool") and tool.Name == "Mended Egg" then
						if tool == v3 then
							return
						else
							update()
						end
					end
				end))
				update()
			end

			self.Maid:Add(localPlayer2.CharacterAdded:Connect(characterAdded))

			if localPlayer2.Character then
				task.spawn(characterAdded, localPlayer2.Character)
			end
		elseif (eggName == "Thirsty Egg" or eggName == "Molten Egg" or eggName == "Falling Sky Egg" or eggName == "Friendly Neighborhood Egg") and not self.Instance:GetAttributes().Collectable then
			if eggName == "Thirsty Egg" then
				local thirstyEgg = egg:WaitForChild("ThirstyEgg")

				if thirstyEgg then
					thirstyEgg.TextureID = "rbxassetid://97597025166696"
				end
			else
				if eggName == "Falling Sky Egg" then
					return
				end

				if eggName == "Molten Egg" then
					local cylinder005 = egg:WaitForChild("Cylinder.005")

					if cylinder005 then
						cylinder005.TextureID = "rbxassetid://96719045735497"
					end

					local surfaceAppearance = cylinder005:WaitForChild("SurfaceAppearance")

					if surfaceAppearance then
						surfaceAppearance:Destroy()
					end
				else
					local friendlyNeighborhoodEgg = eggName == "Friendly Neighborhood Egg" and egg:WaitForChild("Friendly Neighborhood Egg")

					if friendlyNeighborhoodEgg then
						friendlyNeighborhoodEgg.TextureID = "rbxassetid://103619324052821"
					end
				end
			end
		end
	end)
	self.Egg = egg
	local primaryPart = self.Egg.PrimaryPart or self.Egg:FindFirstChild("_PrimaryPart")

	if primaryPart and (primaryPart:IsA("BasePart") or primaryPart:IsA("MeshPart")) then
		if self.Egg.PrimaryPart == nil then
			self.Egg.PrimaryPart = primaryPart
		end

		primaryPart.Anchored = true
	end

	local primaryPart2 = assert(self.Egg.PrimaryPart)
	self.PrimaryPart = primaryPart2
	primaryPart2.CanCollide = false
	primaryPart2.CanTouch = true
	primaryPart2.Anchored = true
	primaryPart2.CanQuery = true
	egg.Name = ""
	local position = self._CFrame.Position
	local v4 = position
	local v5 = createVector(0, 0, 0)
	self.Maid:Add(self.Instance:GetAttributeChangedSignal("CFrame"):Connect(function(...)
		self._CFrame = self.Instance:GetAttribute("CFrame")
		position = self._CFrame.Position
	end))
	local sound

	if self.EggName == "Eggcited Egg" then
		sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://138210540699970"
		sound.Volume = 0.3
		sound.RollOffMaxDistance = 128
		Groups.assign(sound, "HighPriority")
		sound.Parent = egg.PrimaryPart
	else
		sound = nil
	end

	local total = 0
	local v6 = 0
	local v7 = createVector(0, 0, 0)
	self.Maid:Add(RunService.Heartbeat:Connect(function(dt)
		local magnitude = (position - v4).Magnitude

		if not (magnitude > 0.1) then
			total = 0
			return
		end

		local rotation = nil
		local v8 = v4
		v4, v5 = TweenService:SmoothDamp(v4, position, v5, 0.1, nil, dt)

		if magnitude >= 1 and self.EggName == "Eggcited Egg" then
			total += dt
			rotation = CFrame.new(v8, v4).Rotation

			if rotation == rotation then
				if rotation ~= nil then
					rotation *= CFrame.Angles(
						math.lerp(0, 0.4363323129985824, (math.sin(total * 3.141592653589793 * 8))),
						0,
						0
					)
					local v9 = math.ceil(total / 0.25)

					if v9 ~= v6 and sound then
						v6 = v9
						sound:Play()
					end
				end
			else
				rotation = nil
			end
		else
			v6 = 0
			total = 0
		end

		local vector2 = Vector3.new(0, (math.abs(math.sin(total * 3.141592653589793 * 4) * 2)))
		v7 = v7:Lerp(vector2, dt * 20)
		self.Egg:SetAttribute("PositionOverride", v4 + v7)
		self.Egg:SetAttribute("RotationOverride", rotation)
		egg:PivotTo(CFrame.new(v4 + v7) * (rotation or CFrame.identity))
	end))
	self.Maid:Add(self.Instance:GetAttributeChangedSignal("SpawnMyEgg"):Connect(function()
		self:SpawnEgg()
	end))
	self.Maid:Add(localPlayer:GetAttributeChangedSignal("EggXRay"):Connect(function(_: boolean)
		self:Xray()
	end))
	self:Xray()
	local inWater = self.Instance:GetAttribute("InWater")
	self.Egg:PivotTo(CFrame.new(self._CFrame.Position + Vector3.new(
		0,
		primaryPart2.Size.Y * (inWater and 0.2 or 0.5),
		0
	)))
	self._SpawnCF = self.Egg:GetPivot()

	if inWater then
		self.Maid:Add(BobInWater(egg, self._SpawnCF.Position))
	elseif self.Egg:FindFirstChild("AnimationController") then
		local v8 = {
			{ "RollSpin", true },
			{ "RollSpin", false },
			{ "Bounce" },
			{ "Sway" }
		}
		local v9 = v8[math.random(1, #v8)]
		local maid = self.Maid
		local module = require(script.Animations[v9[1]])
		maid:Add(module(egg, v9[2]))
	else
		local maid = self.Maid
		local Rotate = require(script.Animations.Rotate)
		maid:Add(Rotate(egg))
	end

	local child = script.EggFunctions:FindFirstChild(eggName)

	if child then
		local module = require(child)
		module(self, primaryPart2)
	else
		self:ConnectTouched()
	end

	egg.Parent = workspace
end

function v:Start()
	self:SpawnEgg()
	self:ApplyIdleFX()
	self.Maid:Add(function()
		self:PlayPoofFX(1000)
	end)
end

function v.Stop(p)
	p.Maid:Destroy()
end

return v