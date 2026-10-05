local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local module = require("./PassiveHandler")
local SharedWeather = require(ReplicatedStorage.shared.modules.SharedWeather)
local AbaiasSpite = require(ReplicatedStorage.client.legacyControllers.ReplicatedPassiveVfx.AbaiasSpite)
local localPlayer = Players.LocalPlayer
local vfx = ReplicatedStorage.resources:FindFirstChild("vfx")

local function spawnSquallColumn(object, vector2: Vector3?, duration: number)
	if not vfx or typeof(vector2) ~= "Vector3" then
		return
	end

	local model = vfx:FindFirstChild(SharedWeather.IsActive("Raging Squall") and "RagingSquallVFX" or "TropicalSquallVFX")
	local primaryPart = model and model:IsA("Model") and model.PrimaryPart

	if not primaryPart then
		return
	end

	local clone = primaryPart:Clone()

	for _, emitter in clone:GetChildren() do
		if not emitter:IsA("ParticleEmitter") then
			emitter:Destroy()
		end
	end

	clone.Size = createVector(7, 9, 7)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.Transparency = 1
	clone.CFrame = CFrame.new(vector2 + createVector(0, 6, 0))
	clone.Parent = workspace.active.debrisfx
	object:Add(clone)
	task.delay(duration, function()
		if not clone.Parent then
			return
		end

		for _, emitter in clone:GetChildren() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.delay(3, clone.Destroy, clone)
	end)
end

local function resolveChompProgress(config)
	local chompProgressByWeather = config.ChompProgressByWeather

	if chompProgressByWeather then
		for _, v in { "Raging Squall", "Tropical Squall" } do
			if chompProgressByWeather[v] and SharedWeather.IsActive(v) then
				return chompProgressByWeather[v]
			end
		end
	end

	return config.ChompProgress
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getStrikePosition(p)
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	local bobber = tool and tool:FindFirstChild("bobber")

	if bobber and bobber:IsA("BasePart") then
		return bobber.Position
	end

	return p.fishPos
end

local AbaiasSpite2 = {
	Morph = function(p, _, object)
		local config = p.config
		local random = object:GetRandom(23)
		local animTime = config.AnimTime or 0.4
		local fish = object.reel_bar and object.reel_bar:FindFirstChild("fish")
		object:Preload({ script })

		local function playOverlay(childName: string, squallRampTime: number)
			local child = script:FindFirstChild(childName)

			if not (child and fish) then
				return
			end

			local clone = child:Clone()
			clone.Parent = fish

			if clone:IsA("ImageLabel") then
				clone.ImageTransparency = 1
				object.renderTweens:CreateAndPlay(clone, TweenInfo.new(squallRampTime * 0.3), {
					ImageTransparency = 0
				})
				object:DelayLogic(squallRampTime * 0.7, function()
					if clone.Parent then
						object.renderTweens:CreateAndPlay(clone, TweenInfo.new(squallRampTime * 0.3), {
							ImageTransparency = 1
						})
					end
				end)
			end

			object:DelayLogic(squallRampTime, function()
				clone:Destroy()
			end)
			return clone
		end

		p.reelTrove:Add(task.spawn(function()
			if not object.ready then
				object.OnReady:Wait()
			end

			if random:NextNumber(0, 100) >= config.SquallChance then
				return
			end

			playOverlay("squallfx", config.SquallRampTime)
			local reelTrove = p.reelTrove
			local strikePosition = getStrikePosition(object) -- equivalent call inferred; original call site unknown
			spawnSquallColumn(reelTrove, strikePosition, config.SquallRampTime)
			object.fx:SpawnShake(object.reel_bar, 0.12, config.SquallRampTime, 0.02, false)
			local squallProgress = config.SquallProgress
			local squallRampTime = config.SquallRampTime
			local total = 0

			while total < squallRampTime and object.active do
				local v3 = object.OnLogicStep:Wait()
				total += v3
				local v4 = math.min(squallProgress, config.SquallProgress * (v3 / squallRampTime))
				squallProgress -= v4
				object:AddProgress(v4)
			end
		end))
		local swim = AbaiasSpite.Swim(p.reelTrove, function()
			local character = localPlayer.Character
			local tool = character and character:FindFirstChildOfClass("Tool")
			local bobber = tool and tool:FindFirstChild("bobber")

			if bobber and bobber:IsA("BasePart") then
				return bobber.Position
			end

			return object.fishPos
		end)
		local total = 0
		local number = random:NextNumber(config.ChompIntervalMin, config.ChompIntervalMax)
		p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
			if not object.active then
				return
			end

			total += p2

			if total < number then
				return
			end

			total = 0
			number = random:NextNumber(config.ChompIntervalMin, config.ChompIntervalMax)
			object:AddProgress((resolveChompProgress(config)))
			object.core.fish:DelayNextMovement(animTime * 0.5)

			if swim then
				swim:Bite(animTime)
			else
				local strikePosition = getStrikePosition(object) -- equivalent call inferred; original call site unknown

				if strikePosition then
					AbaiasSpite.Surface(p.reelTrove, strikePosition, animTime)
				end
			end

			object.fx:SpawnShake(object.reel_bar, 0.08, animTime, 0.02, false)
		end))
	end
}
setmetatable(AbaiasSpite2, module)
return AbaiasSpite2