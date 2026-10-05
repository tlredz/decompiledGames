local createVector = vector.create
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local Lighting = game:GetService("Lighting")

local function destroyLoadingFXIfExists()
	if script.BlurObject.Value ~= nil then
		script.BlurObject.Value:Destroy()
		script.BlurObject.Value = nil
	end

	if script.AtmosphereObject.Value ~= nil then
		script.AtmosphereObject.Value:Destroy()
		script.AtmosphereObject.Value = nil
	end
end

local function createLoadingFX()
	destroyLoadingFXIfExists()
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = 56
	blurEffect.Name = "TeleportLoadingFX_Blur"
	script.BlurObject.Value = blurEffect
	blurEffect.Parent = Lighting
	local baseAtmosphere = Lighting:FindFirstChild("BaseAtmosphere")

	if baseAtmosphere then
		local clone = baseAtmosphere:Clone()
		clone.Name = "TeleportLoadingFX_Atmosphere"
		clone:SetAttribute("TrueDensity", clone.Density)
		clone.Density = 1
		script.AtmosphereObject.Value = clone
		clone.Parent = Lighting
	end
end

local function fadeOutLoadingFXThenDestroy(duration: number)
	local TweenService = game:GetService("TweenService")

	if script.BlurObject.Value ~= nil then
		local tween = TweenService:Create(
			script.BlurObject.Value,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = 0
			}
		)
		tween:Play()
		tween.Completed:Once(function()
			destroyLoadingFXIfExists()
		end)
	end

	if script.AtmosphereObject.Value ~= nil then
		local value = script.AtmosphereObject.Value
		local tween = TweenService:Create(
			value,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Density = value:GetAttribute("TrueDensity")
			}
		)
		tween:Play()
		tween.Completed:Once(function()
			destroyLoadingFXIfExists()
		end)
	end
end

local util = game.ReplicatedStorage:WaitForChild("Util")
local HeartbeatLoopFor = require(util.HeartbeatLoopFor)
local heartbeatLoopFor = HeartbeatLoopFor.HeartbeatLoopFor
local _ = HeartbeatLoopFor.AwaitHeartbeatLoopFor
local v = false
local connection = nil
local connection2 = nil
local Net = require(game.ReplicatedStorage:WaitForChild("Modules").Net)
Net:RemoteEvent("TeleportLoadingFX").OnClientEvent:Connect(function(p: string, cframe: CFrame?, value: number?)
	if p == "InitRequestStreamAroundAsync" then
		v = true
		createLoadingFX()

		if connection2 ~= nil then
			connection2:Disconnect()
			connection2 = nil
		end

		if connection ~= nil then
			connection:Disconnect()
			connection = nil
		end

		connection = heartbeatLoopFor(5, function() end, function()
			task.spawn(function()
				fadeOutLoadingFXThenDestroy(value or 1)
			end)
			v = false

			if connection ~= nil then
				connection = nil
			end
		end)
	elseif p == "CompletedRequestStreamAroundAsync" and v == true and connection ~= nil then
		if cframe ~= nil then
			connection2 = heartbeatLoopFor(5, function()
				if v == true and connection ~= nil then
					local raycastResult = workspace:Raycast(
						cframe.Position + createVector(0, 7.5, 0),
						createVector(-0, -30, -0),
						raycastParams
					)

					if not (raycastResult and raycastResult.Instance) then
						return
					end

					print(
						"Finished RequestStreamAroundAsync AND some nearby objects were detected via physics check / raycast",
						"yesyes"
					)
					task.spawn(function()
						fadeOutLoadingFXThenDestroy(value or 1)
					end)
					v = false

					if connection2 ~= nil then
						connection2:Disconnect()
						connection2 = nil
					end

					if connection ~= nil then
						connection:Disconnect()
						connection = nil
					end
				else
					if connection2 ~= nil then
						connection2:Disconnect()
						connection2 = nil
					end

					if connection ~= nil then
						connection:Disconnect()
						connection = nil
					end
				end
			end)
			return
		end

		task.spawn(function()
			fadeOutLoadingFXThenDestroy(value or 1)
		end)
		v = false

		if connection ~= nil then
			connection:Disconnect()
			connection = nil
		end
	end
end)