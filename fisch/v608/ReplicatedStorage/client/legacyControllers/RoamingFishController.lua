local createVector = vector.create
game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local v = assert(Players.LocalPlayer)
local LogService = game:GetService("LogService")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
require(packages.Signal)
require(packages.Trove)
local modules = ReplicatedStorage.shared.modules
local SharedRoamingFish = require(modules.SharedRoamingFish)
local fish = require(modules.library.fish)
local spears = require(ReplicatedStorage.shared.modules.library.spears)
local harpoonGuns = require(ReplicatedStorage.shared.modules.library.harpoonGuns)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local mutations = require(ReplicatedStorage.shared.modules.fishing.mutations)
local Bestiary = require(ReplicatedStorage.shared.modules.Bestiary)
local utils = ReplicatedStorage.shared.utils
require(utils.GeneralUtils)
require(utils.NumberUtils)
require(utils.FischUtils)
local assets = require(utils.assets)
local evalColorSequence = require(ReplicatedStorage.shared.utils.evalColorSequence)
local InventoryController = require(ReplicatedStorage.client.legacyControllers.InventoryController)
local ZoneController = require(ReplicatedStorage.client.legacyControllers.ZoneController)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local remoteEvent = Net:RemoteEvent("RoamingFish/Update")
local remoteEvent2 = Net:RemoteEvent("RoamingFish/ContactDamage")
local bitedivine = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing"):WaitForChild("bitedivine")
local _ = SharedRoamingFish.CHUNK_SIZE
local _ = SharedRoamingFish.CHUNK_SIZE_VERTICAL
local CHUNK_SIZE_VECTOR = SharedRoamingFish.CHUNK_SIZE_VECTOR
Vector3.new(0, SharedRoamingFish.CHUNK_VERTICAL_OFFSET, 0)
local _ = CHUNK_SIZE_VECTOR * 0.5
local cloneAsyncsByF = {}
local v2 = {}
local v3 = {}
local flag = false
local roamingFish = workspace.active:WaitForChild("roamingFish")
local v4 = {}
local v5 = playerDataReplicator:TryIndex({ "EquippedAccessories", "Deep Survey Device MK II" })
local v6 = v5 or playerDataReplicator:TryIndex({ "EquippedAccessories", "Deep Survey Device MK I" })
local overlapParams = OverlapParams.new()
overlapParams.RespectCanCollide = false
overlapParams.IncludeInstances = { roamingFish }
local RoamingFishController = {}

local function createHighlight(p)
	local v7 = fish[p.f]

	if not v7 then
		return nil
	end

	local v8 = assert(rarities.Rarities[v7.Rarity], (`Invalid rarity "{v7.Rarity}"`))
	local highlight = Instance.new("Highlight")
	highlight.FillColor = v8.Color
	highlight.OutlineColor = v8.Color
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Name = "RadarHighlight"
	highlight.Parent = p.model
	return highlight
end

local function createBillboard(data)
	local v7 = fish[data.f]

	if not v7 then
		return nil
	end

	local v8 = assert(rarities.Rarities[v7.Rarity], (`Invalid rarity "{v7.Rarity}"`))
	local clone = script.advancedRadar:Clone()

	if Bestiary:IsFishDiscovered(v, data.f, true) then
		clone.fishName.Text = data.f
	else
		clone.fishName.Text = "???"
	end

	clone.fishName.TextTransparency = 1
	clone.fishName.UIStroke.Transparency = 1
	clone.mutationName.TextTransparency = 1
	clone.mutationName.UIStroke.Transparency = 1

	if v8.ColorGradient then
		clone.fishName.UIGradient.Color = v8.ColorGradient
		clone.fishName.UIGradient.Enabled = true
	else
		clone.fishName.TextColor3 = v8.Color
	end

	local v9 = data.m and mutations.Mutations[data.m]

	if v9 == nil then
		clone.mutationName.Visible = false
	else
		clone.mutationName.Text = v9.Display

		if typeof(v9.Color) == "ColorSequence" then
			clone.mutationName.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.mutationName.UIGradient.Color = v9.Color
			clone.mutationName.UIGradient.Enabled = true
		else
			clone.mutationName.TextColor3 = v9.Color
			clone.mutationName.UIGradient.Enabled = false
		end

		clone.mutationName.Visible = true
	end

	clone.Enabled = true
	clone.Parent = data.hitbox
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function deleteHighlight(state)
	if state.highlight then
		state.highlight:Destroy()
		state.highlight = nil
	end

	if state.billboard then
		state.billboard:Destroy()
		state.billboard = nil
	end
end

function RoamingFishController.DeleteFish(p: string)
	local v7 = v4[p]

	if not v7 then
		return
	end

	debug.profilebegin("RoamingFishController::DeleteFish")
	v4[p] = nil

	if v7.model then
		v3[p] = v7.model
		v7.model = nil
		v7.hitbox = nil
		v7.center = nil
	end

	deleteHighlight(v7) -- equivalent call inferred; original call site unknown
	debug.profileend()
end

function RoamingFishController:CreateFish(p2: string)
	v4[p2] = self
	task.spawn(function()
		if v3[p2] then
			local model = v3[p2]
			v3[p2] = nil
			local hitbox = model:FindFirstChild("Hitbox")
			local center = model:FindFirstChild("Center")

			if not (hitbox and hitbox:IsA("BasePart") and center and center:IsA("BasePart")) then
				warn("where hitbox??? how???")
				return
			end

			local currentPosition = SharedRoamingFish.GetCurrentPosition(self)
			model:PivotTo(currentPosition)
			self.model = model
			self.hitbox = hitbox
			self.center = center
			self._last_update = tick()
			self._last_cf = currentPosition
			self._pivot_offset = center.PivotOffset:Inverse()
		else
			if cloneAsyncsByF[self.f] then
				v2[p2] = cloneAsyncsByF[self.f]
				return
			end

			local cloneAsync = assets.getCloneAsync("fish", self.f)

			if not cloneAsync or typeof(cloneAsync) ~= "Instance" or not cloneAsync:IsA("Model") or v4[p2] ~= self then
				return
			end

			cloneAsyncsByF[self.f] = cloneAsync
			v2[p2] = cloneAsync
		end
	end)
end

local random = Random.new()

local function addModel(UID: string, instance)
	local v7 = v4[UID]

	if not v7 then
		return false
	end

	local v8 = fish[v7.f]

	if not v8 then
		return false
	end

	debug.profilebegin("RoamingFishController: create fish model")
	local clone = instance:Clone()
	local hitbox = clone:FindFirstChild("Hitbox")
	local center = clone:FindFirstChild("Center")

	if not (hitbox and hitbox:IsA("BasePart") and center and center:IsA("BasePart")) then
		LogService:Warn("[RoamingFishController] {fishName} has no Hitbox!", {
			fishName = v7.f
		})
		return false
	end

	clone.PrimaryPart = center

	if v7.m then
		local success, result = pcall(mutations.MutateModel, mutations, clone, v7.m, {
			Name = v7.f
		})

		if not success then
			LogService:Warn(
				`[RoamingFishController] Failed to mutate model \{id} (\{fishName}) with \{mutation}: {result}`,
				{
					id = UID,
					fishName = v7.f,
					mutation = v7.m
				}
			)
		end
	end

	local handle = clone:FindFirstChild("handle")

	if handle then
		handle:Destroy()
	end

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Anchored = false
			descendant.Massless = true
			descendant.AudioCanCollide = false
			descendant.CastShadow = false

			if descendant.Material == Enum.Material.Glass then
				descendant.Material = Enum.Material.SmoothPlastic
			elseif descendant.Material == Enum.Material.ForceField then
				descendant.Material = Enum.Material.SmoothPlastic
				descendant.Transparency = 0.5 + descendant.Transparency * 0.5
			end
		elseif descendant:IsA("Light") or descendant:IsA("Sound") or descendant:IsA("Highlight") then
			descendant:Destroy()
		end
	end

	local mouth = center:FindFirstChild("mouth")

	if mouth and mouth:IsA("Attachment") then
		center.PivotOffset = mouth.CFrame.Rotation

		if clone:GetAttribute("FlipForward") then
			center.PivotOffset *= CFrame.fromOrientation(0, 3.141592653589793, 0)
		end
	end

	v7._pivot_offset = center.PivotOffset:Inverse()

	if v7.a > 1 then
		local clones = table.create(v7.a - 1)

		for i = 2, v7.a do
			local clone2 = clone:Clone()
			clone2.Name = `school{i}`
			clone2:PivotTo(center:GetPivot() * CFrame.new(random:NextUnitVector() * hitbox.Size * math.sqrt(v7.a)))
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Name = "SchoolWeld"
			weldConstraint.Part0 = center
			weldConstraint.Part1 = clone2.PrimaryPart
			weldConstraint.Parent = clone2.PrimaryPart
			table.insert(clones, clone2)
		end

		for _, v9 in clones do
			v9.Parent = clone
		end

		hitbox.Size *= math.sqrt(v7.a) * 2
	end

	center.Anchored = true
	hitbox.CanQuery = true
	local currentPosition = SharedRoamingFish.GetCurrentPosition(v7)
	hitbox:SetAttribute("UID", UID)
	hitbox:SetAttribute("FishName", v7.f)
	clone.Name = `{v7.f}_{UID}`
	clone.PrimaryPart = hitbox
	clone:PivotTo(currentPosition)
	clone.Parent = roamingFish:FindFirstChild(v8.Rarity)
	v7.model = clone
	v7.hitbox = hitbox
	v7.center = center
	v7._last_update = tick()
	v7._last_cf = currentPosition
	hitbox.Size = hitbox.Size:Max(clone:GetExtentsSize())
	hitbox:AddTag("RoamingFishHitbox")

	if fish[v7.f].Rarity == "Divine Secret" then
		local clone2 = bitedivine:Clone()
		clone2:RemoveTag("FishingSound")
		clone2.RollOffMaxDistance = 1024
		clone2.RollOffMode = Enum.RollOffMode.InverseTapered
		clone2.Parent = hitbox
		clone2:Play()
	end

	debug.profileend()
	return true
end

local centers = {}
local v7 = {}

function RoamingFishController.Tick(p: number)
	local humanoidRootPart = v and v.Character and v.Character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	debug.profilebegin("RoamingFishController::Tick")
	local serverTimeNow = workspace:GetServerTimeNow()
	debug.profilebegin("RoamingFishController: stream models")

	while true do
		local id, v9 = next(v2)
		local flag2 = false

		if id and v9 then
			v2[id] = nil
			flag2 = addModel(id, v9)
		else
			for _, v10 in cloneAsyncsByF do
				v10:Destroy()
			end

			table.clear(cloneAsyncsByF)
		end

		if not (not id or flag2) then
			continue
		end

		local v10, v11 = next(v3)

		if v10 and v11 then
			v3[v10] = nil
			v11:Destroy()
		end

		debug.profileend()
		local chunk = SharedRoamingFish.GetChunk(humanoidRootPart.Position)
		local now = tick()

		for k, fish2 in v4 do
			if not fish2 then
				continue
			end

			if serverTimeNow - (fish2.b + fish2.t) > (fish2.p and 1200 or 300) then
				LogService:Warn("[RoamingFishController] fish {id} ({f}) timed out", {
					id = k,
					f = fish2.f,
					fish = fish2
				})
				RoamingFishController.DeleteFish(k)
			elseif (not fish2.z or fish2.z == ZoneController.CurrentZoneName) and (fish2.u == nil or fish2.u == ZoneController.IsUnderground) then
				local v13

				if fish2._last_cf and fish2._last_update then
					v13 = now - fish2._last_update
					local magnitude = (chunk - SharedRoamingFish.GetChunk(fish2._last_cf)).Magnitude

					if magnitude > 2 then
						if v13 < 0.1 then
							continue
						end
					elseif magnitude > 1 and v13 < 0.03333333333333333 then
						continue
					end
				else
					v13 = p
				end

				local currentPosition = SharedRoamingFish.GetCurrentPosition(fish2, serverTimeNow)

				if fish2._last_update and fish2._last_cf and fish2._spring_vel then
					local smoothDamp, spring_vel = TweenService:SmoothDamp(
						fish2._last_cf,
						currentPosition,
						fish2._spring_vel,
						0.25,
						nil,
						v13
					)
					fish2._last_cf = smoothDamp
					fish2._spring_vel = spring_vel
				else
					fish2._last_cf = currentPosition
					fish2._spring_vel = CFrame.identity
				end

				if fish2.center and fish2._last_cf ~= nil then
					table.insert(centers, fish2.center)
					table.insert(v7, fish2._last_cf * fish2._pivot_offset)
				end

				local v14 = flag and ((currentPosition.Position - humanoidRootPart.Position) * createVector(1, 0, 1)).Magnitude - (not fish2.hitbox and 0 or fish2.hitbox.Size.Magnitude / 2 or 0) < 64

				if v14 and fish2.model then
					if not fish2.highlight then
						fish2.highlight = createHighlight(fish2)
					end

					if not fish2.billboard and v5 then
						fish2.billboard = createBillboard(fish2)
					end
				end

				if fish2.highlight then
					local rarity = rarities.Rarities[fish[fish2.f].Rarity]

					if rarity.ColorGradient then
						local v15 = evalColorSequence(rarity.ColorGradient, now / #rarity.ColorGradient.Keypoints % 1)
						fish2.highlight.FillColor = v15
						fish2.highlight.OutlineColor = v15
					end

					if v14 then
						if fish2.highlight.OutlineTransparency > 0 then
							local v15 = math.clamp(fish2.highlight.OutlineTransparency - v13 * 2, 0, 1)
							fish2.highlight.OutlineTransparency = v15
							fish2.highlight.FillTransparency = v15 * 0.5 + 0.5

							if fish2.billboard then
								fish2.billboard.fishName.TextTransparency = v15
								fish2.billboard.fishName.UIStroke.Transparency = v15 * 0.75 + 0.25
								fish2.billboard.mutationName.TextTransparency = v15
								fish2.billboard.mutationName.UIStroke.Transparency = v15 * 0.75 + 0.25
							end
						end
					else
						local v15 = math.clamp(fish2.highlight.OutlineTransparency + v13 * 0.3333333333333333, 0, 1)
						fish2.highlight.OutlineTransparency = v15
						fish2.highlight.FillTransparency = v15 * 0.5 + 0.5

						if fish2.billboard then
							fish2.billboard.fishName.TextTransparency = v15
							fish2.billboard.fishName.UIStroke.Transparency = v15 * 0.75 + 0.25
							fish2.billboard.mutationName.TextTransparency = v15
							fish2.billboard.mutationName.UIStroke.Transparency = v15 * 0.75 + 0.25
						end

						if v15 >= 1 then
							deleteHighlight(fish2) -- equivalent call inferred; original call site unknown
						end
					end
				end

				fish2._last_update = now
			end
		end

		debug.profilebegin("RoamingFishController: move models")
		workspace:BulkMoveTo(centers, v7, Enum.BulkMoveMode.FireCFrameChanged)
		table.clear(centers)
		table.clear(v7)
		debug.profileend()
		debug.profileend()
		break
	end
end

local v8 = {}

function RoamingFishController.TickContact()
	debug.profilebegin("RoamingFishController::TickContact")
	local character = v.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		local partBoundsInBox = workspace:GetPartBoundsInBox(
			humanoidRootPart.CFrame,
			createVector(3, 6, 2),
			overlapParams
		)

		for _, v9 in ipairs(partBoundsInBox) do
			local UID = v9:GetAttribute("UID")

			if v8[UID] then
				continue
			end

			local v10 = fish[v9:GetAttribute("FishName")]

			if not (v10 ~= nil and v10.ContactDamage ~= nil) then
				continue
			end

			v8[UID] = true
			remoteEvent2:FireServer(UID)
			local v11 = UID
			task.delay(0.5, function()
				v8[v11] = nil
			end)
		end
	end

	debug.profileend()
end

function RoamingFishController.Start(_)
	remoteEvent.OnClientEvent:Connect(function(items)
		debug.profilebegin("RoamingFishController: handle packet")

		for k, item in items do
			if item == 0 then
				RoamingFishController.DeleteFish(k)
			else
				local v9 = v4[k]

				if v9 then
					local a = v9.a
					local m = v9.m

					for k2, v10 in item do
						v9[k2] = v10
					end

					if not item.p then
						v9.p = nil
					end

					if item.a and a and item.a < a and v9.model then
						debug.profilebegin("RoamingFishController: update amount")

						for i = a, item.a + 1, -1 do
							local child = v9.model:FindFirstChild((`school{i}`))

							if child then
								child:Destroy()
							end
						end

						debug.profileend()
					end

					if item.m and item.m ~= m and v9.model ~= nil then
						task.spawn(mutations.MutateModel, mutations, v9.model, item.m, {
							Name = v9.f
						})

						if v9.billboard ~= nil and v9.billboard:FindFirstChild("mutationName") ~= nil then
							local mutation = mutations.Mutations[item.m]

							if mutation == nil then
								v9.billboard.mutationName.Visible = false
							else
								v9.billboard.mutationName.Text = mutation.Display

								if typeof(mutation.Color) == "ColorSequence" then
									v9.billboard.mutationName.TextColor3 = Color3.fromRGB(255, 255, 255)
									v9.billboard.mutationName.UIGradient.Color = mutation.Color
									v9.billboard.mutationName.UIGradient.Enabled = true
								else
									v9.billboard.mutationName.TextColor3 = mutation.Color
									v9.billboard.mutationName.UIGradient.Enabled = false
								end

								v9.billboard.mutationName.Visible = true
							end
						end
					end
				elseif item.f then
					RoamingFishController.CreateFish(item, k)
				end
			end
		end

		debug.profileend()
	end)
	RunService.PreSimulation:Connect(RoamingFishController.Tick)
	RunService.PostSimulation:Connect(RoamingFishController.TickContact)
	local v9 = {
		["Fish Radar"] = true
	}

	for k in spears do
		v9[k] = true
	end

	for k in harpoonGuns do
		v9[k] = true
	end

	InventoryController.EquippedToolChanged:Connect(function(p)
		local radarEnabled

		if v6 then
			radarEnabled = v:GetAttribute("RadarEnabled")
		elseif p == nil then
			radarEnabled = false
		else
			radarEnabled = v9[p.Name]

			if radarEnabled then
				radarEnabled = v:GetAttribute("RadarEnabled")
			end
		end

		flag = radarEnabled
	end)
	v:GetAttributeChangedSignal("RadarEnabled"):Connect(function()
		local equippedTool = InventoryController.EquippedTool
		local radarEnabled

		if v6 then
			radarEnabled = v:GetAttribute("RadarEnabled")
		elseif equippedTool == nil then
			radarEnabled = false
		else
			radarEnabled = v9[equippedTool.Name]

			if radarEnabled then
				radarEnabled = v:GetAttribute("RadarEnabled")
			end
		end

		flag = radarEnabled
	end)
	playerDataReplicator:Observe({ "EquippedAccessories", "Deep Survey Device MK II" }, function(p)
		v5 = p ~= nil
		v6 = p ~= nil or playerDataReplicator:TryIndex({ "EquippedAccessories", "Deep Survey Device MK I" }) ~= nil
		local equippedTool = InventoryController.EquippedTool
		local radarEnabled

		if v6 then
			radarEnabled = v:GetAttribute("RadarEnabled")
		elseif equippedTool == nil then
			radarEnabled = false
		else
			radarEnabled = v9[equippedTool.Name]

			if radarEnabled then
				radarEnabled = v:GetAttribute("RadarEnabled")
			end
		end

		flag = radarEnabled
	end)
	playerDataReplicator:Observe({ "EquippedAccessories", "Deep Survey Device MK I" }, function(p)
		v6 = v5 or p ~= nil
		local equippedTool = InventoryController.EquippedTool
		local radarEnabled

		if v6 then
			radarEnabled = v:GetAttribute("RadarEnabled")
		elseif equippedTool == nil then
			radarEnabled = false
		else
			radarEnabled = v9[equippedTool.Name]

			if radarEnabled then
				radarEnabled = v:GetAttribute("RadarEnabled")
			end
		end

		flag = radarEnabled
	end)
	remoteEvent:FireServer()
	task.spawn(function()
		while task.wait(1) do
			if v:GetAttribute("RoamerClientDebug") ~= true then
				continue
			end

			local serverTimeNow = workspace:GetServerTimeNow()
			local count = 0
			local count2 = 0
			local count3 = 0
			local count4 = 0
			local count5 = 0
			local count6 = 0
			local count7 = 0
			local count8 = 0
			local count9 = 0

			for k, v10 in v4 do
				if v10 then
					count += 1

					if v10.model then
						count2 += 1
					end

					if v10.highlight then
						count3 += 1
					end

					if v10.billboard then
						count4 += 1
					end

					if serverTimeNow - (v10.b + v10.t) > 5 then
						count5 += 1
					end

					if v10.p then
						count6 += 1
					end
				else
					warn("How", k)
				end
			end

			for _, _ in v2 do
				count7 += 1
			end

			for _, _ in v3 do
				count8 += 1
			end

			for _, _ in cloneAsyncsByF do
				count9 += 1
			end

			print("------------------")
			print((`Total fish: {count}\nBusy fish: {count6}\nStale fish: {count5}\nActive models: {count2}\nActive highlights: {count3}\nActive billboards: {count4}\nModel add queue size: {count7}\nModel remove queue size: {count8}\nModel cache size: {count9}`))
		end
	end)
end

return RoamingFishController