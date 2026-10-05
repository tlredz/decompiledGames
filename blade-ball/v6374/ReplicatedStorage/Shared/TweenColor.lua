local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local v2 = require3(ReplicatedStorage2.Packages.Observers)
require3(ReplicatedStorage2.Shared.FastUtils)
local v3 = require3(ReplicatedStorage2.Packages.Signal)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Packages.Trove)
local currentCamera = workspace.CurrentCamera
local v6 = 1
local count = 0
local instances = {}
local v7 = {}
local v8 = {}
local v9 = 1
local gameSettings = UserSettings().GameSettings
local v10 = {
	UIStroke = true,
	Decal = true,
	PointLight = true,
	SpotLight = true,
	Beam = true,
	Trail = true,
	ParticleEmitter = true,
	UIGradient = true,
	SurfaceAppearance = true
}
v4.Thread.Every(0.5, function()
	if v.TouchEnabled and not (v.KeyboardEnabled or v.MouseEnabled) then
		v9 = gameSettings.SavedQualityLevel.Value < 10 and 1.35 or 1.15
	else
		v9 = 1
	end

	for _, attachment in instances do
		local v11

		if attachment:IsA("Attachment") then
			v11 = attachment.WorldCFrame
		else
			v11 = attachment:GetPivot()
		end

		local magnitude = (v11.Position - currentCamera.CFrame.Position).Magnitude
		v7[attachment] = math.clamp(magnitude / 50, 1, 1.7)
		v8[attachment] = math.clamp(magnitude / 50, 1, 3)
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function getConfigFromRoot(instance)
	local colorConfig = instance:GetAttribute("ColorConfig") or instance.Name
	local child = ReplicatedStorage2.TweenColorConfig:FindFirstChild(colorConfig)
	return child and require3(child)
end

local function update(p, instance, watchCallback)
	if instance.Name == "IgnoreChangeColor" or instance:GetAttribute("IgnoreChangeColor") or not (v10[instance.ClassName] or instance:IsA("GuiObject") or instance:IsA("BasePart")) or instance:IsA("BasePart") and instance.Name ~= "ChangeColor" and p ~= instance then
		return
	else
		return watchCallback(instance)
	end
end

local v11 = {}

local function useCachedColorValue(colorConfig: string, fn)
	local v12 = v11[colorConfig]

	if not v12 then
		local color3Value = Instance.new("Color3Value")
		color3Value.Name = colorConfig
		color3Value.Parent = script
		local trove = v5.new()
		trove:Add(color3Value)
		v12 = {
			Color3Value = color3Value,
			Trove = trove,
			Connections = {}
		}
		v11[colorConfig] = v12
		local v14 = fn(color3Value)

		if v14 then
			trove:Add(v14)
		end
	end

	local GUID = HttpService:GenerateGUID(false)
	v12.Connections[GUID] = true
	return v12.Color3Value, function()
		v12.Connections[GUID] = nil

		if not next(v12.Connections) then
			v12.Trove:Destroy()
			v11[colorConfig] = nil
		end
	end
end

local function getColor3(instance, configFromRoot, flag: boolean?)
	local colors = configFromRoot.Colors

	if configFromRoot.ShouldSync then
		local syncSeed = configFromRoot.SyncSeed or 0
		local total = 0

		for _, color in colors do
			total += color.TweenInfo.Time
		end

		local function getColorAtTime(serverTimeNow: number)
			local v12 = (serverTimeNow + syncSeed) % total
			local total2 = 0
			local color = nil
			local value = nil
			local color2 = nil

			for k, color3 in colors do
				local tweenInfo = color3.TweenInfo
				local time = tweenInfo.Time
				total2 += time

				if not (v12 < total2) then
					continue
				end

				color2 = color3.Color
				color = (colors[k + 1] or colors[1]).Color
				value = TweenService:GetValue(
					(time - (total2 - v12)) / time,
					tweenInfo.EasingStyle,
					tweenInfo.EasingDirection
				)
				break
			end

			return color2:Lerp(color, value)
		end

		if flag then
			return useCachedColorValue(instance:GetAttribute("ColorConfig") or instance.Name, function(p)
				return RunService.PostSimulation:Connect(function(_: number)
					p.Value = getColorAtTime(workspace:GetServerTimeNow())
				end)
			end)
		end

		return getColorAtTime(workspace:GetServerTimeNow())
	elseif flag then
		return useCachedColorValue(instance:GetAttribute("ColorConfig") or instance.Name, function(p)
			local maid = v5.new()
			local tweens = table.create(#colors)

			for k, color in colors do
				local tween = TweenService:Create(p, color.TweenInfo, {
					Value = color.Color
				})
				tweens[k] = tween
				maid:Add(function()
					tween:Cancel()
					tween:Destroy()
				end)
			end

			local flag2 = true
			maid:Add(function()
				flag2 = false
			end)
			maid:Add(task.spawn(function()
				while flag2 do
					for _, v12 in tweens do
						local v13 = v12
						task.defer(function()
							v13:Play()
						end)
						v12.Completed:Wait()
					end
				end
			end))
			return maid
		end)
	else
		return colors[1].Color
	end
end

local TweenColor = {}

function TweenColor.Update(folder)
	local configFromRoot = getConfigFromRoot(folder) -- equivalent call inferred; original call site unknown

	if not configFromRoot then
		return
	end

	local colors = configFromRoot.Colors
	local color

	if configFromRoot.ShouldSync then
		local syncSeed = configFromRoot.SyncSeed or 0
		local total = 0

		for _, color2 in colors do
			total += color2.TweenInfo.Time
		end

		local function getColorAtTime(serverTimeNow: number)
			local v12 = (serverTimeNow + syncSeed) % total
			local total2 = 0
			local color2 = nil
			local value = nil
			local color3 = nil

			for k, color4 in colors do
				local tweenInfo = color4.TweenInfo
				local time = tweenInfo.Time
				total2 += time

				if not (v12 < total2) then
					continue
				end

				color3 = color4.Color
				color2 = (colors[k + 1] or colors[1]).Color
				value = TweenService:GetValue(
					(time - (total2 - v12)) / time,
					tweenInfo.EasingStyle,
					tweenInfo.EasingDirection
				)
				break
			end

			return color3:Lerp(color2, value)
		end

		color = getColorAtTime(workspace:GetServerTimeNow())
	else
		color = colors[1].Color
	end

	local v12 = {
		Color3 = color,
		ColorSequence = ColorSequence.new(color)
	}

	local function watchCallback(p)
		if typeof(p.Color) == "ColorSequence" then
			p.Color = v12.ColorSequence
		else
			p.Color = v12.Color3
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateObject(p)
		update(folder, p, watchCallback)
	end

	for _, descendant in folder:GetDescendants() do
		updateObject(descendant) -- equivalent call inferred; original call site unknown
	end

	updateObject(folder) -- equivalent call inferred; original call site unknown
end

function TweenColor.Watch(instance)
	local configFromRoot = getConfigFromRoot(instance) -- equivalent call inferred; original call site unknown

	if not configFromRoot then
		return
	end

	local updateFrequency = configFromRoot.UpdateFrequency or 3
	local updateInterval = configFromRoot.UpdateInterval or 0.25
	local maid = v5.new()

	if instance:IsA("PVInstance") or instance:IsA("Attachment") then
		table.insert(instances, instance)
		maid:Add(function()
			local index = table.find(instances, instance)

			if index then
				table.remove(instances, index)
			end

			v7[instance] = nil
			v8[instance] = nil
		end)
	end

	local color3, v12 = getColor3(instance, configFromRoot, true)
	assert(typeof(color3) == "Instance")
	assert(v12)
	maid:Add(v12)
	local v13 = v3.new()
	maid:Add(v13)

	local function watchCallback(instance2)
		count += 1
		local v14 = count

		if instance2:IsA("Decal") then
			return v13:Connect(function(p)
				local v15 = math.floor(updateFrequency * (v7[instance] or 1) * v9)

				if v14 % v15 ~= v6 % v15 then
					return
				end

				instance2.Color3 = p.Color3
			end)
		end

		if instance2:IsA("TextLabel") or instance2:IsA("TextButton") then
			return v13:Connect(function(p)
				local v15 = math.floor(updateFrequency * (v7[instance] or 1) * v9)

				if v14 % v15 ~= v6 % v15 then
					return
				end

				instance2.TextColor3 = p.Color3
			end)
		end

		if instance2:IsA("ImageButton") or instance2:IsA("ImageLabel") then
			return v13:Connect(function(p)
				local v15 = math.floor(updateFrequency * (v7[instance] or 1) * v9)

				if v14 % v15 ~= v6 % v15 then
					return
				end

				instance2.ImageColor3 = p.Color3
			end)
		end

		if typeof(instance2.Color) == "ColorSequence" then
			return v13:Connect(function(p)
				local v15 = math.floor(updateFrequency * (v7[instance] or 1) * v9)

				if v14 % v15 ~= v6 % v15 then
					return
				end

				instance2.Color = p.ColorSequence
			end)
		end

		return v13:Connect(function(p)
			local v15 = math.floor(updateFrequency * (v7[instance] or 1) * v9)

			if v14 % v15 ~= v6 % v15 then
				return
			end

			instance2.Color = p.Color3
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onObjectAdded(instance2)
		return update(instance, instance2, watchCallback)
	end

	maid:Add(v2.observeDescendants(instance, onObjectAdded))
	xpcall(function()
		local v14 = onObjectAdded(instance) -- equivalent call inferred; original call site unknown

		if v14 then
			maid:Add(v14)
		end
	end, warn)
	local now = os.clock()
	v13:Fire({
		Color3 = color3.Value,
		ColorSequence = ColorSequence.new(color3.Value)
	})
	maid:Add(color3.Changed:Connect(function(color: Color3)
		local v14 = updateInterval * (v8[instance] or 1) * v9
		local now2 = os.clock()

		if now2 - now < v14 then
			return
		end

		now = now2
		v6 += 1
		v13:Fire({
			Color3 = color,
			ColorSequence = ColorSequence.new(color)
		})
	end))
	return function()
		maid:Destroy()
	end
end

return TweenColor