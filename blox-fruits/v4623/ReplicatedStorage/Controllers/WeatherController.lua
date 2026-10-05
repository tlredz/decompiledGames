local Flags = require(game.ReplicatedStorage.Modules.Flags)

if not Flags.WEATHER_ENABLED then
	return {}
end

require(game.ReplicatedStorage.Controllers.WeatherController.Types)
local WeatherData = require(game.ReplicatedStorage.Modules.Weather.WeatherData)
local State = require(game.ReplicatedStorage.Modules.State)
local Raycast = require(game.ReplicatedStorage.Modules.World.Raycast)
local WeatherUtil = require(script.WeatherUtil)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local GachaWindow = require(game.ReplicatedStorage.Controllers.UI.GachaWindow)
local _ = game.Players.LocalPlayer
local v = {
	Inside = false,
	Ceiling = 0,
	TimeNotUnderCeiling = 0,
	TimeUnderCeiling = 0,
	TimeWentInside = 0,
	TimeWentOutside = 0
}

local function findCeiling(_)
	local cFrame = workspace.CurrentCamera.CFrame
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = WeatherUtil.precipitationIgnoreList

	for _, precipitationType in pairs(WeatherUtil.precipitationTypes) do
		if precipitationType.emitter then
			raycastParams:AddToFilter(precipitationType.emitter)
		end
	end

	local raycast = Raycast({
		origin = CFrame.new(cFrame.Position),
		direction = Vector3.new(0, WeatherUtil.SCAN_HEIGHT, 0),
		raycastParams = raycastParams
	})
	return raycast or nil
end

local v2 = false
local v3 = false

local function step(p: string, p2: number)
	local position = workspace.CurrentCamera.CFrame.Position

	if p == "_RenderStepped" then
		v2 = false
	end

	local isOpen = GachaWindow:IsOpen()

	for _, precipitationType in pairs(WeatherUtil.precipitationTypes) do
		if not (precipitationType:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false) then
			continue
		end

		v3 = true

		if p == "_RenderStepped" then
			if not v2 then
				v2 = true
				local v4

				if precipitationType.insideCheck then
					v4 = precipitationType.insideCheck()
				end

				local v5

				if v4 == nil then
					v5 = findCeiling(precipitationType.config)
				end

				local ceiling = WeatherUtil.precipitationState:Get("Ceiling")
				local timeUnderCeiling = WeatherUtil.precipitationState:Get("TimeUnderCeiling")
				local timeNotUnderCeiling = WeatherUtil.precipitationState:Get("TimeNotUnderCeiling")
				local inside = WeatherUtil.precipitationState:Get("Inside")
				local v6 = isOpen and true or v4

				if v6 or v5 then
					if v6 then
						if timeUnderCeiling >= 0.5 then
							if isOpen or not inside then
								WeatherUtil.precipitationState:Set("Inside", true)
								WeatherUtil.precipitationState:Set("Ceiling", v6 and 0 or v5 and v5.Position.Y or 0)
								WeatherUtil.precipitationState:Set("TimeNotUnderCeiling", 0)
								WeatherUtil.precipitationState:Set("TimeWentInside", tick())
								WeatherUtil.precipitationState:Set("TimeWentOutside", nil)
							end
						else
							WeatherUtil.precipitationState:Set("TimeUnderCeiling", p2 + timeUnderCeiling)
						end
					elseif (ceiling or 0) < position.y then
						if timeUnderCeiling >= 0.5 then
							if isOpen or not inside then
								WeatherUtil.precipitationState:Set("Inside", true)
								WeatherUtil.precipitationState:Set("Ceiling", v6 and 0 or v5 and v5.Position.Y or 0)
								WeatherUtil.precipitationState:Set("TimeNotUnderCeiling", 0)
								WeatherUtil.precipitationState:Set("TimeWentInside", tick())
								WeatherUtil.precipitationState:Set("TimeWentOutside", nil)
							end
						else
							WeatherUtil.precipitationState:Set("TimeUnderCeiling", p2 + timeUnderCeiling)
						end
					end
				elseif not v5 or v6 == false then
					if v6 == false or timeNotUnderCeiling >= 0.2 then
						if inside then
							WeatherUtil.precipitationState:Set("Inside", false)
							WeatherUtil.precipitationState:Set("Ceiling", 0)
							WeatherUtil.precipitationState:Set("TimeUnderCeiling", 0)
							WeatherUtil.precipitationState:Set("TimeWentOutside", tick())
							WeatherUtil.precipitationState:Set("TimeWentInside", nil)
						end
					else
						WeatherUtil.precipitationState:Set("TimeNotUnderCeiling", p2 + timeNotUnderCeiling)
					end
				end
			end

			precipitationType:_RenderStepped(p2)
		elseif p == "_Stepped" then
			precipitationType:_Stepped(p2)
		end
	end

	if not v2 and v3 then
		v3 = false
		WeatherUtil.precipitationState:Set("Inside", false)
		WeatherUtil.precipitationState:Set("Ceiling", 0)
		WeatherUtil.precipitationState:Set("TimeUnderCeiling", 0)
		WeatherUtil.precipitationState:Set("TimeNotUnderCeiling", 0)
		WeatherUtil.precipitationState:Set("TimeWentInside", nil)
		WeatherUtil.precipitationState:Set("TimeWentOutside", nil)
	end
end

return {
	VISUALIZE_STATE = false,
	OnStart = function(_)
		for k, v4 in pairs(v) do
			WeatherUtil.precipitationState:Set(k, v4)
		end

		for _, moduleScript in pairs(script.Precipitation.Singletons:GetChildren()) do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			if WeatherData.precipitationTypes[moduleScript.Name] then
				local module = require(moduleScript)
				local v4 = false
				local v5 = moduleScript
				task.delay(1, function()
					if not v4 then
						warn(script.Name, "Hanging", v5)
					end
				end)
				v4 = true
				WeatherUtil.precipitationTypes[moduleScript.Name] = module
			else
				warn("Precipitation type not added", moduleScript.Name)
			end
		end

		for k in WeatherData.singletons do
			if WeatherData.precipitationTypes[k] then
				WeatherUtil.locks[k] = WeatherUtil.locks.Precipitation:Extend()
			else
				WeatherUtil.locks[k] = WeatherUtil.locks.Global:Extend()
			end

			local v4 = {
				Name = k,
				Enabled = false,
				TimeEnabled = os.clock(),
				TimeDisabled = os.clock()
			}
			local property = WeatherData.properties[k]

			if property then
				for k2, v5 in pairs(property) do
					v4[k2] = v5
				end
			end

			local v5 = State.new(v4)

			for k2, v6 in pairs(v4) do
				v5:Set(k2, v6)
			end

			WeatherUtil.states[k] = v5
			local v6 = WeatherData.types[k][k]

			if not v6._CameraEffect then
				continue
			end

			local clones = {
				UID = k,
				Name = k
			}

			for k2, clone in pairs(v6) do
				if typeof(clone) == "table" then
					clone = table.clone(clone) or clone
				end

				clones[k2] = clone
			end

			WeatherData:Zero(clones)

			if WeatherData.precipitationTypes[k] then
				local PrecipitationComponent = require(script.Weather.Components.PrecipitationComponent)
				PrecipitationComponent.new(clones)
			elseif k == "Clouds" then
				local CloudsComponent = require(script.Weather.Components.CloudsComponent)
				CloudsComponent.new(clones)
			else
				warn((`Unknown singleton: {k}`))
			end
		end

		local __Commands = game.ReplicatedStorage:FindFirstChild("__Commands")

		if __Commands and __Commands:FindFirstChild("Weather") then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateInitial(child)
				local value = child.Value == true
				local lock = WeatherUtil.locks[child.Name]

				if value then
					lock:Lock("_Commands")
				else
					lock:Unlock("_Commands")
				end
			end

			for _, child in pairs(__Commands.Weather:GetChildren()) do
				local lock = WeatherUtil.locks[child.Name]
				updateInitial(child) -- equivalent call inferred; original call site unknown
				child.Changed:Connect(function(p)
					if p then
						lock:Lock("_Commands")
					else
						lock:Unlock("_Commands")
					end
				end)
			end
		end

		local function updateEnabledState(p, object)
			local isLocked = object:IsLocked()

			for _, component in pairs(WeatherUtil.components) do
				if isLocked then
					if p == "Global" or p == component.name then
						component:Disable()
					end
				else
					if p == "Precipitation" then
						if not WeatherData.precipitationTypes[component.name] then
							continue
						end
					elseif component.name ~= p then
						continue
					end

					if not component._enabled then
						component:Enable()
					end
				end
			end
		end

		for k, lock in pairs(WeatherUtil.locks) do
			if k == "Global" then
				continue
			end

			updateEnabledState(k, lock)
			local v4 = k
			local v5 = lock
			lock:Connect(function(p, p2)
				updateEnabledState(v4, v5)
			end)
		end

		local RunService = game:GetService("RunService")
		RunService.RenderStepped:Connect(function(dt)
			step("_RenderStepped", dt)
		end)
		local RunService2 = game:GetService("RunService")
		RunService2.Stepped:Connect(function(time)
			step("_Stepped", time)
		end)
		WeatherUtil.locks.Global:Unlock("_Init")
	end
}