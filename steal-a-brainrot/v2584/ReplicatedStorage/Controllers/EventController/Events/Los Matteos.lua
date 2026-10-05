local createVector = vector.create
game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local LosMatteos = {}
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local SharedEventUtils = require(ReplicatedStorage.Shared.SharedEventUtils)
local EvLightning = require(ReplicatedStorage.Packages.EvLightning)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
local MapInformation = require(ReplicatedStorage.Shared.MapInformation)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Utils.MathUtils)
require(ReplicatedStorage.Shared.Snapshot)
require(script.TreeRootAnimator)
local Shake = require(ReplicatedStorage.Packages.Shake)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local children = script.Clouds:GetChildren()
local cloudsStartBigger

if ServerData.IsBiggerServer() then
	cloudsStartBigger = workspace.Events["Los Matteos"].CloudsStartBigger
else
	cloudsStartBigger = workspace.Events["Los Matteos"].CloudsStart
end

local cloudsEndBigger

if ServerData.IsBiggerServer() then
	cloudsEndBigger = workspace.Events["Los Matteos"].CloudsEndBigger
else
	cloudsEndBigger = workspace.Events["Los Matteos"].CloudsEnd
end

local remoteEvent = Net:RemoteEvent("EventService/Los Matteos/CreateLightningBolt")
local isTsunamiServer = ServerData.IsTsunamiServer()
local isJumpLTMServer = ServerData.IsJumpLTMServer()
local raycastParams = RaycastParams.new()
local v2

if ServerData.IsBiggerServer() then
	v2 = workspace.Events["Los Matteos"].AreasBigger
else
	v2 = workspace.Events["Los Matteos"].Areas
end

raycastParams.FilterDescendantsInstances = { v2 }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local maid = Trove.new()
local part = Instance.new("Part")
part.Anchored = true
part.CanCollide = false
part.TopSurface = Enum.SurfaceType.Smooth
part.BottomSurface = Enum.SurfaceType.Smooth
part.Material = Enum.Material.Neon
part.Color = Color3.fromRGB(96, 234, 255)
local v3 = Shake.new()
v3.Amplitude = 3
v3.Frequency = 0.1
v3.FadeInTime = 0
v3.FadeOutTime = 0.6
v3.PositionInfluence = createVector(0.5, 0.5, 0.5)
v3.RotationInfluence = createVector(2.5, 0.5, 0.5)

local function initActivationVisual()
	local maid2 = maid:Extend()
	local v4 = table.create(4)
	maid2:Add(function()
		table.clear(v4)
	end)
	local total = 0
	maid2:Add(RunService.PreRender:Connect(function(dt: number)
		debug.profilebegin("Los Matteos Event")
		total += dt

		for k, v5 in v4 do
			if not (v5.target and v5.targetAttachment) then
				continue
			end

			v5.beam.First.Enabled = true
			v5.beam.Second.Enabled = true
			local v6 = math.clamp(total - k + 1, 0, 1)
			local worldPosition = v5.beam.WorldPosition
			v5.targetAttachment.Position = worldPosition + (v5.target:GetPivot().Position - worldPosition) * v6
		end

		debug.profileend()
	end))
	maid2:Add(Observers.observeTag("LosMatteosPlayerVFX", function(parent)
		local clone = script.PlayerVFX.Beam:Clone()
		clone.Parent = parent
		local clone2 = script.PlayerVFX.Torso:Clone()
		clone2.Parent = parent
		local losMatteosIndex = parent:GetAttribute("LosMatteosIndex")
		v4[losMatteosIndex] = {
			beam = clone,
			target = nil
		}
		local v5 = Observers.observeTag("LosMatteosPlayerVFX", function(target)
			if not (target ~= parent and target:GetAttribute("LosMatteosIndex") == parent:GetAttribute("LosMatteosIndex") % 3 + 1) then
				return nil
			end

			local attachment = Instance.new("Attachment")
			attachment.Position = clone.WorldPosition
			attachment.Parent = workspace.Terrain
			local v6 = v4[parent:GetAttribute("LosMatteosIndex")]
			v6.target = target
			v6.beam.First.Attachment0 = attachment
			v6.beam.Second.Attachment0 = attachment
			v6.targetAttachment = attachment
			return function()
				attachment:Destroy()
			end
		end)
		return function()
			clone2:Destroy()
			clone:Destroy()
			v5()
			v4[losMatteosIndex] = nil
		end
	end))
end

function LosMatteos.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	local losMatteosSpawn = ReplicatedStorage:GetAttribute("LosMatteosSpawn")

	if not losMatteosSpawn then
		losMatteosSpawn = MapInformation.MapCenter.Position
		local raycastResult = workspace:Raycast(losMatteosSpawn, createVector(-0, -25, -0), raycastParams)

		if raycastResult then
			losMatteosSpawn = Vector3.new(losMatteosSpawn.X, raycastResult.Position.Y, losMatteosSpawn.Z)
		end
	end

	ReplicatedStorage:SetAttribute("LosMatteosEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("LosMatteosEvent", nil)
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function calculateTimeLeftFor(p)
		return activeEventData.startedAt + p - workspace:GetServerTimeNow()
	end

	local function growTree(folder, p: number, callback)
		local function growPart(state, size: Vector3, p2: number, flag: boolean?)
			local cFrame = state.CFrame
			local vector2 = Vector3.new(flag and 0 or size.X, 0, flag and 0 or size.Z)
			local cFrame2 = cFrame * CFrame.new(0, -(size.Y - vector2.Y) / 2, 0)
			state.Size = vector2
			state.CFrame = cFrame2
			local transparency = state.Transparency
			state.Transparency = 1
			local maid2 = maid
			local v5

			if callback then
				v5 = callback(p2)
			else
				v5 = p2
			end

			maid2:Add(task.delay(v5, function()
				state.Transparency = transparency
				local v6 = not callback and 1 or callback(p2 + 1)
				local tweenInfo = TweenInfo.new(v6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				CreateTween(state, tweenInfo, {
					Size = size
				})
				CreateTween(state, tweenInfo, {
					CFrame = cFrame
				})
			end))
		end

		local parts = {}
		local v4 = 1e999
		local v5 = -1e999

		for _, part2 in folder:GetDescendants() do
			if not (part2:IsA("BasePart") and part2.Transparency < 1) then
				continue
			end

			table.insert(parts, part2)
			v4 = math.min(v4, part2.Position.Y)
			v5 = math.max(v5, part2.Position.Y)
		end

		table.sort(parts, function(a, b)
			return a.Position.Y < b.Position.Y
		end)
		local v6 = v5 - v4

		for _, v7 in parts do
			local v8 = v7.Color.R * 255 < 90
			local v9 = (v7.Position.Y - v4) / v6 * p

			if v8 then
				v9 += 0.2
			end

			growPart(v7, v7.Size, v9, v8)
		end
	end

	if not isTsunamiServer then
		maid:Add(task.spawn(function()
			SoundController:PlaySound(ReplicatedStorage.Sounds.Events["Los Matteos"].Grow, losMatteosSpawn, false)
		end))
	end

	maid:Add(task.delay(calculateTimeLeftFor(isTsunamiServer and 1 or 3), function()
		ReplicatedStorage:SetAttribute("LosMatteosEventNightTime", true)
		maid:Add(function()
			ReplicatedStorage:SetAttribute("LosMatteosEventNightTime", nil)
		end)
		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()

		if not isTsunamiServer then
			local clone = maid:Clone(script.Tree)
			clone:PivotTo(CFrame.new(losMatteosSpawn))

			if ReplicatedStorage:GetAttribute("LosMatteosEventIsRainbow") then
				for _, descendant in clone.Leaves:GetDescendants() do
					descendant:SetAttribute("RainbowIgnoreTransparency", true)
					descendant:AddTag("RainbowModel")
				end
			end

			clone.Parent = workspace
			growTree(clone, 5, function(p: number)
				return calculateTimeLeftFor(p + 3)
			end)
		end
	end))

	if not isTsunamiServer then
		maid:Add(task.delay(calculateTimeLeftFor(7), function()
			ReplicatedStorage.Sounds.Events["Los Matteos"].Roots:Play()
		end))
		maid:Add(function()
			ReplicatedStorage.Sounds.Events["Los Matteos"].Roots:Stop()
		end)
		maid:Add(ReplicatedStorage:GetAttributeChangedSignal("LosMatteosGrowing"):Connect(function()
			ReplicatedStorage.Sounds.Events["Los Matteos"].Roots.Looped = ReplicatedStorage:GetAttribute("LosMatteosGrowing") ~= false
		end))
		maid:Add(Observers.observeTag("LosMatteos_Tree", function(p)
			growTree(p, 1)
			return nil
		end))
		maid:Add(Observers.observeCharacter(Players.LocalPlayer, function(_, p)
			return maid:Add(Observers.observeAttribute(p, "Matteo_CollectedTree", function(p2)
				if p2 then
					return maid:Add(Observers.observeTag("LosMatteos_TreePrompt", function(p3)
						p3.Enabled = false
						return function()
							p3.Enabled = true
						end
					end, { workspace }))
				end

				return nil
			end))
		end))
	end

	local v5 = {}
	local v6 = nil

	if isTsunamiServer then
		local areas = workspace.Map:FindFirstChild("Areas")

		if areas then
			local v7 = 1e999
			local v8 = -1e999
			local v9 = 1e999
			local v10 = -1e999
			local total = 0
			local count = 0

			for _, part2 in areas:GetChildren() do
				if not part2:IsA("BasePart") then
					continue
				end

				local pivot = part2:GetPivot()
				local v11 = part2.Size.X / 2
				local v12 = part2.Size.Z / 2
				v7 = math.min(v7, pivot.Position.X - v11)
				v8 = math.max(v8, pivot.Position.X + v11)
				v9 = math.min(v9, pivot.Position.Z - v12)
				v10 = math.max(v10, pivot.Position.Z + v12)
				total += pivot.Position.Y
				count += 1
			end

			local ground = workspace.Map:FindFirstChild("Ground")

			if ground then
				local pivot = ground:GetPivot()
				local v11 = ground.Size.X / 2
				local v12 = ground.Size.Z / 2
				v7 = math.min(v7, pivot.Position.X - v11)
				v8 = math.max(v8, pivot.Position.X + v11)
				v9 = math.min(v9, pivot.Position.Z - v12)
				v10 = math.max(v10, pivot.Position.Z + v12)
				total += pivot.Position.Y
				count += 1
			end

			local v11 = total / math.max(1, count)
			v6 = {
				StartPos = Vector3.new((v7 + v8) / 2, v11 + 150, v9),
				StartSize = Vector3.new(v8 - v7, 0, v10 - v9),
				EndPos = Vector3.new((v7 + v8) / 2, v11 + 150, v10 + 100)
			}
		end
	end

	local v7 = {}

	if isJumpLTMServer then
		local track = workspace.Map:FindFirstChild("Track")

		if track then
			for _, child in track:GetChildren() do
				local island = child:FindFirstChild("Island")

				if not island then
					continue
				end

				local v8 = 1e999
				local v9 = -1e999
				local v10 = 1e999
				local v11 = -1e999
				local v12 = -1e999

				for _, v13 in island:QueryDescendants("BasePart"), nil, nil do
					local pivot = v13:GetPivot()
					local v14 = v13.Size.X / 2
					local v15 = v13.Size.Z / 2
					v8 = math.min(v8, pivot.Position.X - v14)
					v9 = math.max(v9, pivot.Position.X + v14)
					v10 = math.min(v10, pivot.Position.Z - v15)
					v11 = math.max(v11, pivot.Position.Z + v15)
					v12 = math.max(v12, pivot.Position.Y + v13.Size.Y / 2)
				end

				if v12 ~= -1e999 then
					table.insert(v7, {
						StartPos = Vector3.new((v8 + v9) / 2, v12 + 60, v10),
						StartSize = Vector3.new(math.floor((v9 - v8) / 2) * 2, 0, math.floor((v11 - v10) / 2) * 2),
						EndPos = Vector3.new((v8 + v9) / 2, v12 + 60, v11 + 30)
					})
				end
			end
		end
	end

	local function startClouds()
		local function spawnCloud(value: number?, value2: number?)
			local v8

			if isJumpLTMServer and #v7 > 0 then
				v8 = v7[math.random(1, #v7)]
			end

			local startPos

			if v8 then
				startPos = v8.StartPos
			elseif isTsunamiServer and v6 then
				startPos = v6.StartPos
			else
				startPos = cloudsStartBigger.Position
			end

			local startSize

			if v8 then
				startSize = v8.StartSize
			elseif isTsunamiServer and v6 then
				startSize = v6.StartSize
			else
				startSize = cloudsStartBigger.Size
			end

			local endPos

			if v8 then
				endPos = v8.EndPos
			elseif isTsunamiServer and v6 then
				endPos = v6.EndPos
			else
				endPos = cloudsEndBigger.Position
			end

			local clone = maid:Clone(children[math.random(1, #children)])
			clone.Transparency = 1
			local v9

			if v8 then
				v9 = startPos.Z + math.random(0, startSize.Z)
			elseif isTsunamiServer and v6 then
				v9 = startPos.Z + math.random(0, startSize.Z)
			else
				v9 = startPos.Z + (value or 0) * 30 + (value2 or 0)
			end

			clone.CFrame = CFrame.new(startPos.X + math.random(-startSize.X * 0.5, startSize.X * 0.5), startPos.Y, v9)
			local vector2 = Vector3.new(clone.Position.X, startPos.Y, endPos.Z)

			if vector.dot(endPos - startPos, vector2 - clone.Position) < 0 then
				return
			end

			clone.Parent = workspace.Camera
			local v10 = {
				instance = clone,
				speed = math.clamp(50 / clone.Size.Magnitude, 5, 15) * (math.random(80, 120) / 100),
				startPos = clone.Position,
				endPos = vector2
			}
			maid:Add(CreateTween(
				clone,
				TweenInfo.new(
					0.5,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out,
					0,
					false,
					(value2 or 0) * 0.1 + (math.abs(value or 0) + 1) * 0.5
				),
				{
					Transparency = 0
				}
			))
			table.insert(v5, v10)
			return v10
		end

		if isJumpLTMServer then
			for i = 1, #v7 * 4 do
				spawnCloud(0, i)
			end
		elseif isTsunamiServer then
			maid:Add(task.spawn(function()
				local count = 0
				local count2 = 0

				while count < 250 do
					for _ = 1, math.random(1, 3) do
						if count >= 250 then
							break
						end

						spawnCloud(count2, count)
						count += 1

						if count % 3 == 1 then
							count2 += 1
						end
					end

					task.wait(0.08)
				end
			end))
		else
			local count = 0

			for i = 1, 50 do
				spawnCloud(count, i)

				if i % 3 == 1 then
					count += 1
				end
			end
		end

		maid:Add(RunService.PostSimulation:Connect(function(dt)
			debug.profilebegin("Los Matteos:Clouds")

			for i = #v5, 1, -1 do
				local v8 = v5[i]
				local instance = v8.instance
				local position = instance.Position
				local normalized = vector.normalize(v8.endPos - position)
				local v9 = vector.magnitude(v8.endPos - position)
				local v10 = v8.speed * dt
				local endPos

				if v9 < v10 then
					endPos = v8.endPos
					table.remove(v5, i)
					local instance2 = instance
					maid:Add(CreateTween(instance, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Transparency = 1
					})).Completed:Once(function()
						maid:Remove(instance2)
					end)
					spawnCloud()
				else
					endPos = position + normalized * v10
				end

				SharedEventUtils.pushPartCFrame(instance, CFrame.lookAt(endPos, endPos + normalized))
			end

			debug.profileend()
		end))
	end

	maid:Add(task.delay(calculateTimeLeftFor(isTsunamiServer and 3 or 8), function()
		if isJumpLTMServer then
			maid:Add(JumpLTMWeather.Cover(script.RainWeather))
			return
		end

		local clone = maid:Clone(script.RainWeather)
		clone.Parent = workspace

		if ServerData.IsBiggerServer() then
			ClientEventUtils.resizeEffects(clone, 2)
		end
	end))
	maid:Add(remoteEvent.OnClientEvent:Connect(function(p: number, position: Vector3, flag: boolean?)
		local random = Random.new(p)
		local magnitude = (workspace.CurrentCamera.CFrame.Position - position).Magnitude

		if magnitude <= 75 then
			local clone = v3:Clone()
			local v9 = (1 - magnitude / 75 * 0.5) ^ 2
			clone.Amplitude *= v9
			clone.RotationInfluence *= v9
			maid:Add(ShakePresets.BindShakeToCamera(clone))
			clone:Start()
		end

		local instances = {}

		for _, v9 in v5 do
			if ((v9.instance.Position - position) * createVector(1, 0, 1)).Magnitude < 100 then
				table.insert(instances, v9.instance)
			end
		end

		local position2

		if #instances > 0 then
			local parent = instances[random:NextInteger(1, #instances)]
			position2 = parent.Position
			SoundController:PlaySound(
				ReplicatedStorage.Sounds.Events["Los Matteos"]["Lightning Strike"],
				parent.Position,
				false
			)
			local color = parent.Color
			parent.Color = Color3.fromRGB(90, 109, 161)
			CreateTween(parent, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Color = color
			})

			for _, child in script.CloudParticles:GetChildren() do
				local clone = child:Clone()
				clone.Parent = parent
				VFX.emit(clone)
				Debris:AddItem(clone, 2)
			end
		else
			position2 = position + createVector(0, 70, 0)
		end

		local v9 = EvLightning.create(position2, position, {
			bends = 4,
			thickness = 1,
			max_depth = 1,
			fork_bends = 1,
			fork_chance = 30,
			decay = 3,
			material = Enum.Material.Neon
		})
		local model = Instance.new("Model")
		v9.model = model
		model.Name = "LightningBolt"
		local lines = v9:GetLines()
		table.sort(lines, function(a, b)
			return a.origin.Y > b.origin.Y
		end)
		local Y = lines[#lines].origin.Y
		local Y2 = lines[1].origin.Y
		local v10 = Y2 - Y
		local v11 = v9.random:NextInteger(10, 20) / 100
		local clones = table.create(#lines)

		for k, line in lines do
			if line.goal.Y < position.Y then
				continue
			end

			local v12 = math.max((Y2 - line.origin.Y) / v10 * v11, 0)
			local clone = part:Clone()
			clone.Size = Vector3.new(
				v9.thickness - line.depth * 2 * 0.1,
				v9.thickness - line.depth * 2 * 0.1,
				(line.origin - line.goal).Magnitude + 0.5
			)
			clone.CFrame = CFrame.new((line.goal + line.origin) / 2, line.goal)
			clone.Transparency = 1
			clone.Parent = model
			clones[k] = clone
			CreateTween(clone, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, v12), {
				Transparency = line.transparency
			})
		end

		task.delay(v11 + 0.05, function()
			local clone

			if flag then
				clone = script.StrikeBrainrot:Clone()
			else
				clone = script.Strike:Clone()
			end

			clone.Position = position
			clone.Parent = workspace
			VFX.emit(clone)

			if flag then
				SoundController:PlaySound(ReplicatedStorage.Sounds.Events["Los Matteos"].Hit, position, false)
			else
				SoundController:PlaySound(ReplicatedStorage.Sounds.Events["Los Matteos"].HitNothing, position, false)
			end

			for _, v12 in clones do
				local v13 = v12
				task.spawn(function()
					v13.Transparency = 0
					task.wait(0.1)
					v13.Transparency = 1
					task.wait(0.1)
					CreateTween(v13, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
						Transparency = 0.4
					})
				end)
			end

			task.delay(v9.options.decay or 1, function()
				clone:Destroy()
				model:Destroy()
				v9.destroyed = true
			end)
		end)
		model.Parent = workspace.CurrentCamera
		v9.drew = true
	end))
	startClouds()

	if not isTsunamiServer then
		maid:Add(task.spawn(function()
			initActivationVisual()
		end))
	end
end

function LosMatteos.OnStop(_)
	maid:Destroy()
end

function LosMatteos.OnLoad(_)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
end

return LosMatteos