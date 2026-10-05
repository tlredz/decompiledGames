local createVector = vector.create

if not workspace.StreamingEnabled then
	return
end

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Notification"))
require(ReplicatedStorage.Util.Graphics)
require(ReplicatedStorage.Util.BodyMover)
local ProcessUtil = require(ReplicatedStorage.Util.ProcessUtil)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag(script.Name):traceback():build()
assert(true, "stream in distance needs to be less than stream out distance")
local v2 = RunService:IsStudio() and false
local streamingEnabled = workspace.StreamingEnabled
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
ProcessUtil.IS_DEBUG_WARN_ENABLED = v2
local map = workspace:WaitForChild("Map")
workspace:WaitForChild("_WorldOrigin")
ReplicatedStorage:WaitForChild("Unloaded")
local tagged = CollectionService:GetTagged("Detail")
local fakeIslands = ReplicatedFirst:WaitForChild("FakeIslands")
workspace:WaitForChild("Terrain")
local v3 = {}
local v4 = {}
local v5 = {}
local info = v.info
local warn = v.warn

function getIfFakeShown(p: number, p2: number, flag: boolean)
	local v6 = math.max(4096, p2)

	if flag then
		return v6 + 350 < p
	end

	return v6 + 450 < p
end

function tryUpdateDebugAttributes()
	if not v2 then
		return
	end

	for k, v6 in pairs(v3) do
		k:SetAttribute("IsRendered", v6.IsRendered)
		k:SetAttribute("MaxDistance", v6.MaxDistance)
		k:SetAttribute("Position", v6.Position)
		k:SetAttribute("TimeAtUnload", v6.TimeAtUnload)
	end
end

function setVisibility(folder, flag: boolean, flag2: boolean, callback)
	v5[folder] = v5[folder] or {}

	for _, v6 in pairs(v5[folder]) do
		v6:Cancel()
	end

	v5[folder] = {}
	local v6 = v5[folder]

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		if typeof((part:GetAttribute("FakeOriginalTransparency"))) == "nil" then
			part:SetAttribute("FakeOriginalTransparency", part.Transparency)
		end

		local fakeOriginalTransparency

		if flag then
			fakeOriginalTransparency = part:GetAttribute("FakeOriginalTransparency")
			assert(typeof(fakeOriginalTransparency) == "number")
		else
			fakeOriginalTransparency = 1
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false

		if flag2 then
			local v8

			if flag then
				v8 = tweenInfo
			else
				v8 = tweenInfo2
			end

			local v9 = TweenService:Create(part, v8, {
				Transparency = fakeOriginalTransparency
			})
			local completedConnection = nil
			local destroyingConnection = nil
			v6[part] = v9
			local flag3 = true
			local v10 = part

			local function cleanUp(flag4: boolean)
				if not flag3 then
					return
				end

				flag3 = false

				if destroyingConnection then
					destroyingConnection:Disconnect()
				end

				if completedConnection then
					completedConnection:Disconnect()
				end

				v6[v10] = nil
				local count = 0

				for k, v11 in pairs(v6) do
					count += 1
				end

				if count == 0 and callback then
					callback(flag4)
				end
			end

			local cleanUp2 = cleanUp
			destroyingConnection = part.Destroying:Connect(function()
				cleanUp2(false)
			end)
			local cleanUp3 = cleanUp
			completedConnection = v9.Completed:Connect(function(p)
				if p == Enum.PlaybackState.Completed then
					cleanUp3(true)
				elseif p == Enum.PlaybackState.Cancelled then
					cleanUp3(false)
				end
			end)
		else
			part.Transparency = fakeOriginalTransparency
		end
	end

	for _, v7 in pairs(v6) do
		v7:Play()
	end

	if not flag2 and callback then
		task.spawn(function()
			callback(true)
		end)
	end
end

function unloadIsland(instance, p)
	info((`unloading "{instance:GetFullName()}"`))
	v4[instance] = {
		Job = "unload-" .. HttpService:GenerateGUID(false)
	}
	CollectionService:AddTag(instance, "Loading")
	local job = v4[instance].Job
	tick()
	task.spawn(function()
		local bindableEvent = Instance.new("BindableEvent")
		local flag = false
		setVisibility(p.LODModel, true, true, function(flag2: boolean)
			flag = flag2
			bindableEvent:Fire()
		end)
		bindableEvent.Event:Wait()
		bindableEvent:Destroy()

		if not flag or v4[instance].Job ~= job or v4[instance].Job ~= job then
			return
		end

		v4[instance] = {
			Job = "done"
		}
		CollectionService:RemoveTag(instance, "Loading")
	end)
end

function loadIsland(instance, data)
	info((`loading "{instance:GetFullName()}"`))
	v4[instance] = {
		Job = "load-" .. HttpService:GenerateGUID(false)
	}
	local job = v4[instance].Job
	CollectionService:AddTag(instance, "Loading")
	local humanoidRootPart

	if Players.LocalPlayer.Character then
		humanoidRootPart = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	else
		humanoidRootPart = nil
	end

	local function getIfInside()
		if humanoidRootPart then
			local maxDistance = data.MaxDistance

			if humanoidRootPart:IsA("BasePart") and maxDistance then
				return (humanoidRootPart.Position * createVector(1, 0, 1) - data.Position * createVector(1, 0, 1)).Magnitude < maxDistance
			end
		end

		return false
	end

	tick()
	task.spawn(function()
		local v6

		if humanoidRootPart then
			local maxDistance = data.MaxDistance

			if humanoidRootPart:IsA("BasePart") and maxDistance then
				v6 = (humanoidRootPart.Position * createVector(1, 0, 1) - data.Position * createVector(1, 0, 1)).Magnitude < maxDistance
			else
				v6 = false
			end
		else
			v6 = false
		end

		info((`{data.LODModel.Name}, isInside={v6}`))
		setVisibility(data.LODModel, false, not v6)

		if v4[instance].Job ~= job then
			return
		end

		v4[instance] = {
			Job = "done"
		}
		CollectionService:RemoveTag(instance, "Loading")
	end)
end

function tryInitIsland(parent)
	info((`tryInitIsland -> "{parent:GetFullName()}"`))
	local child = fakeIslands:FindFirstChild(parent.Name)

	if not child then
		info((`no fake island with name "{parent.Name}" found for "{parent:GetFullName()}"`))
		return false
	end

	assert(child)
	local clone = child:Clone()

	for _, part in ipairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	setVisibility(clone, false, false)
	clone.Parent = parent
	local levelOfDetailDiameter = clone:GetAttribute("LevelOfDetailDiameter")
	local levelOfDetailOrigin = clone:GetAttribute("LevelOfDetailOrigin")

	if typeof(levelOfDetailDiameter) == "number" and typeof(levelOfDetailOrigin) == "Vector3" then
		v3[parent] = {
			Position = levelOfDetailOrigin,
			LODModel = clone,
			IsRendered = true,
			MaxDistance = levelOfDetailDiameter / 2
		}
		return true
	end

	warn((`bad attributes for island {parent:GetFullName()}`))
	return false
end

Players.LocalPlayer:GetPropertyChangedSignal("TeamColor"):Wait()

if streamingEnabled then
	info("initialize map streaming")

	for _, model in ipairs(map:GetChildren()) do
		if model:IsA("Model") then
			local v6 = {}
			local instances = {}

			for _, instance in ipairs(tagged) do
				if instance:IsDescendantOf(model) then
					assert(
						instance:IsA("BasePart") or instance:IsA("Model"),
						(`"Detail" tagged inst "{instance:GetFullName()}" is not a model / part, it is a {instance.ClassName}`)
					)
					table.insert(v6, instance)
				else
					table.insert(instances, instance)
				end
			end

			tryInitIsland(model)
			tagged = instances
		else
			info((`map child "{model.Name}" is not a Model, it's a "{model.ClassName}"`))
		end
	end

	tryUpdateDebugAttributes()
else
	info((`not loading islands because MAP_STREAMING_LOD={streamingEnabled}`))
end

info((`starting update loop, details found={#tagged}`))

for i, v6 in ipairs(tagged) do
	info((`{i}-Detail: {v6:GetFullName()}`))
end

local now = 0
RunService.Heartbeat:Connect(function(_: number)
	if tick() - now < 0.2 then
		return
	end

	now = tick()
	local position = workspace.CurrentCamera.CFrame.Position

	for k, v6 in pairs(v3) do
		local magnitude = (v6.Position * createVector(1, 0, 1) - position * createVector(1, 0, 1)).Magnitude

		if getIfFakeShown(magnitude, v6.MaxDistance, not v6.IsRendered) then
			if v6.IsRendered then
				local timeAtUnload = v6.TimeAtUnload

				if not timeAtUnload then
					timeAtUnload = tick()
					v6.TimeAtUnload = timeAtUnload
				end

				assert(timeAtUnload)

				if tick() - timeAtUnload > 1.5 then
					v6.TimeAtUnload = nil
					v6.IsRendered = false
					unloadIsland(k, v6)
				end
			end
		else
			if v6.TimeAtUnload then
				v6.TimeAtUnload = nil
			end

			if v6.IsRendered == false then
				v6.TimeAtUnload = nil
				v6.IsRendered = true
				loadIsland(k, v6)
			end
		end
	end

	tryUpdateDebugAttributes()
end)