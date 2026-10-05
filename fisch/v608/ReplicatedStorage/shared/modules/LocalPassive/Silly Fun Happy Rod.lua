local SillyFunHappyRod = {}
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local module = require("./PassiveHandler")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v = {}

function bindFunc(object, callback)
	assert(object and callback, "Missing args.")
	assert(typeof(object) == "RBXScriptSignal", "Invalid signal.")
	assert(typeof(callback) == "function", "Invalid function.")
	task.spawn(function()
		object:Wait()
		callback()
	end)
end

function bindProp(instance, propertyName, p)
	assert(instance and propertyName and p, "Missing args.")
	assert(typeof(instance) == "Instance", "Invalid instance.")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		instance[propertyName] = p
	end

	local connection = instance:GetPropertyChangedSignal(propertyName):Connect(update)
	update() -- equivalent call inferred; original call site unknown
	v[instance] = v[instance] or {}
	table.insert(v[instance], connection)
end

function cleanup(instance, object)
	assert(instance and object, "Missing args.")
	assert(typeof(instance) == "Instance", "Invalid instance.")
	assert(typeof(object) == "RBXScriptSignal", "Invalid signal.")
	object:Wait()
	instance:Destroy()
end

function tween(instance, p, p2)
	assert(instance and p and p2, "Missing args.")
	assert(typeof(instance) == "Instance", "Invalid instance.")
	assert(typeof(p) == "TweenInfo", "Invalid tweeninfo.")
	assert(typeof(p2) == "table", "Invalid property table.")
	local tween2 = TweenService:Create(instance, p, p2)
	tween2.Completed:Once(function()
		tween2:Destroy()
	end)
	tween2:Play()
	return tween2
end

function unbind(instance)
	assert(instance, "Missing args.")
	assert(typeof(instance) == "Instance", "Invalid instance.")

	if not v[instance] then
		return
	end

	for _, connection in v[instance] do
		connection:Disconnect()
	end
end

function SillyFunHappyRod.Morph(_, parent, object)
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, { script })

	if object.isSimplified then
		object:AddModifier("resilience", "force", 50)
	end

	local random = object:GetRandom(5)
	bindProp(parent.fish.icon, "ImageColor3", Color3.fromRGB(255, 0, 0))
	bindProp(parent.playerbar, "BackgroundColor3", Color3.fromRGB(255, 255, 0))
	bindProp(parent.progress.bar, "BackgroundColor3", Color3.fromRGB(255, 0, 0))
	object.OnFishExitBar:Connect(function()
		object:AddProgress(-100)
	end)
	local v2 = {
		function()
			object:WaitUntilReady()
			local v3 = math.random(120, 360)
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				if parent.Parent then
					parent.Rotation = (parent.Rotation + v3 * dt) % 360
				else
					renderSteppedConnection:Disconnect()
				end
			end)
		end,
		function()
			object:WaitUntilReady()

			while parent.Parent do
				local position = parent.Position
				local uDim = UDim2.new(math.random(), math.random(), math.random(), math.random())
				local v3 = position.X.Scale - uDim.X.Scale
				local v4 = position.Y.Scale - uDim.Y.Scale
				local v5 = math.sqrt(v3 ^ 2 + v4 ^ 2) / 1.25
				tween(parent, TweenInfo.new(v5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
					Position = uDim
				}).Completed:Wait()
				local clone = script.honk:Clone()
				local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect", clone)
				pitchShiftSoundEffect.Octave = 1
				clone.Parent = playerGui
				clone:Play()
				task.spawn(cleanup, clone, clone.Ended)
			end
		end,
		function()
			object.OnMinigameEnd:Wait()

			for _ = 1, 10 do
				ReplicatedStorage.events.debug_catch:Fire({
					Name = "Nessie",
					Weight = math.random(80000, 90000) / 10,
					Sparkling = true,
					Shiny = true,
					SubValues = {
						Fast = true,
						Mutation = "Atlantean"
					}
				})
			end

			ReplicatedStorage.events.anno_localthought:Fire("just kidding lol", nil, 2, nil, nil, nil, 1.5)
		end,
		function()
			object.OnMinigameEnd:Wait()
			local screenGui = Instance.new("ScreenGui", playerGui)
			screenGui.DisplayOrder = -1
			screenGui.IgnoreGuiInset = true
			local clone = script.freddy:Clone()
			clone.BackgroundTransparency = 1
			clone.ImageTransparency = 1
			clone.Parent = screenGui
			local clone2 = script.scream:Clone()
			clone2.Parent = playerGui
			clone.ImageTransparency = 0
			clone2:Play()
			Debris:AddItem(screenGui, 3)
			Debris:AddItem(clone2, 3)
		end,
		function()
			task.wait(0.2)
			local clone = script.roar:Clone()
			clone.Parent = playerGui
			local clone2 = script.boss:Clone()
			clone2.Volume = 0
			clone2.Parent = parent
			clone:Play()
			task.spawn(function()
				cleanup(clone, clone.Ended)
				clone2:Play()
				tween(clone2, TweenInfo.new(1), {
					Volume = 0.5
				})
				cleanup(clone2, parent.Parent.Destroying)
			end)
			local idle = localPlayer.Character:FindFirstChildOfClass("Tool").handle:FindFirstChild("Idle")

			if idle then
				tween(idle, TweenInfo.new(1), {
					Volume = 0
				})
				bindFunc(parent.Parent.Destroying, function()
					tween(idle, TweenInfo.new(1), {
						Volume = 0.25
					})
				end)
			end

			task.wait(1.2)
			local screenGui = Instance.new("ScreenGui", playerGui)
			screenGui.DisplayOrder = -1
			screenGui.IgnoreGuiInset = true
			local frame = Instance.new("Frame")
			frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			frame.Position = UDim2.fromScale(0, 0)
			frame.Size = UDim2.fromScale(1, 0)
			local frame2 = Instance.new("Frame")
			frame2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			frame2.Position = UDim2.fromScale(0, 1)
			frame2.Size = UDim2.fromScale(1, 1)
			frame.Parent = screenGui
			frame2.Parent = screenGui
			local uDim = UDim2.fromScale(0.5, 0.5)
			local v3 = math.sqrt((parent.Position.X.Scale - uDim.X.Scale) ^ 2 + (parent.Position.Y.Scale - uDim.Y.Scale) ^ 2) / 0.2
			tween(frame, TweenInfo.new(1), {
				Size = UDim2.fromScale(1, 0.2)
			})
			tween(frame2, TweenInfo.new(1), {
				Position = UDim2.fromScale(0, 0.8)
			})
			tween(parent, TweenInfo.new(v3), {
				Position = UDim2.fromScale(0.5, 0.5)
			})

			for _, v4 in { parent.playerbar, parent.progress.bar } do
				unbind(v4)
				local tween2 = tween(v4, TweenInfo.new(1), {
					BackgroundColor3 = Color3.fromRGB(65, 6, 18)
				})
				local v5 = v4
				bindFunc(tween2.Completed, function()
					bindProp(v5, "BackgroundColor3", Color3.fromRGB(65, 6, 18))
				end)
			end

			object:TweenModifier("barSize", "force", 1, 0.01, TweenInfo.new(1))
			parent.Parent.Destroying:Wait()
			tween(frame, TweenInfo.new(1), {
				Size = UDim2.fromScale(1, 0)
			})
			tween(frame2, TweenInfo.new(1), {
				Position = UDim2.fromScale(0, 1)
			})
			Debris:AddItem(frame, 1)
			Debris:AddItem(frame2, 1)
		end
	}
	local troll = object.rod and object.rod:GetAttribute("Troll")

	if typeof(troll) == "number" and v2[troll] then
		task.spawn(v2[troll])
	else
		task.spawn(v2[random:NextInteger(1, #v2)])
	end
end

setmetatable(SillyFunHappyRod, module)
return SillyFunHappyRod