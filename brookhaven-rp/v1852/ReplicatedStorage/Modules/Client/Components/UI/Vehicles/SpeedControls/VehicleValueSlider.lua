local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local ValueSlider = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.ValueSlider)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local VehicleUiInteractionTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.VehicleUiInteractionTelemetryController)
local v = Component.new({
	Tag = "VehicleValueSlider"
})
local v2 = {
	Drift = {
		set = VehicleController.SetDriftStrength,
		changed = VehicleController.OnDriftStrengthChanged,
		getInitial = VehicleController.GetCurrentDriftStrength
	},
	Suspension = {
		set = VehicleController.SetSuspensionLevel,
		changed = VehicleController.OnSuspensionHeightChanged,
		getInitial = VehicleController.GetDefaultSuspensionLevel,
		getMax = VehicleController.GetSuspensionLevelCount
	},
	Turbo = {
		set = VehicleController.SetTurbo,
		changed = VehicleController.OnTurboChanged,
		getInitial = VehicleController.GetCurrentTurboLevel
	},
	Speed = {
		set = VehicleController.SetMaxSpeed,
		changed = VehicleController.OnMaxSpeedChanged,
		getInitial = VehicleController.GetCurrentMaxSpeed,
		getMax = VehicleController.GetMaxSpeedAllowed,
		watchMax = true
	}
}

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local apply = self.Instance:GetAttribute("Apply")
	local v3

	if typeof(apply) == "string" then
		v3 = v2[apply] or nil
	else
		v3 = nil
	end

	if v3 == nil then
		warn("VehicleValueSlider needs Apply set to a known feature, got:", apply)
		return
	end

	local component = ComponentUtil.GetComponentFromInstance(self.Instance, ValueSlider)

	if component == nil then
		return
	end

	local value = component:GetValue()
	local thread = nil

	local function fireIfChanged(p2: number)
		if p2 == value then
			return
		end

		local v4 = value
		value = p2

		if apply == "Speed" then
			VehicleUiInteractionTelemetryController.Fire("Speed", v4 < p2 and "Increase Speed" or "Decrease Speed")
		elseif apply == "Drift" then
			VehicleUiInteractionTelemetryController.Fire("Speed", v4 < p2 and "Increase Drift" or "Decrease Drift")
		elseif apply == "Turbo" then
			if p2 >= 1 then
				VehicleUiInteractionTelemetryController.Fire("Speed", "Turbo - " .. tostring(p2))
			end
		elseif apply == "Suspension" then
			VehicleUiInteractionTelemetryController.Fire("Speed", "Suspension - " .. tostring(p2))
		end
	end

	local v4 = nil
	local flag = false
	local v5 = nil

	local function acceptServerValue()
		if component:IsDragging() or v4 ~= nil or flag then
			return
		end

		local v6 = v5
		v5 = nil
		VehicleController.AcceptServerValue(v3.changed, v6)

		if typeof(v6) == "number" then
			component:SetValue(v6)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function flush()
		if flag then
			return
		end

		flag = true
		task.spawn(function()
			local v6 = false

			while v4 ~= nil do
				local v7 = v4
				v4 = nil
				v6 = v3.set(v7) ~= true
			end

			flag = false
			v5 = nil

			if v6 and v3.getInitial ~= nil then
				local initial = v3.getInitial()

				if typeof(initial) == "number" then
					v5 = initial
				end
			end

			if not component:IsDragging() and v4 == nil then
				if flag then
					return
				end

				local v7 = v5
				v5 = nil
				VehicleController.AcceptServerValue(v3.changed, v7)

				if typeof(v7) == "number" then
					component:SetValue(v7)
				end
			end
		end)
	end

	self._Janitor:Add(component.OnChanged:Connect(function(p2: number)
		v4 = p2
		VehicleController.PredictValue(v3.changed, p2)
		flush() -- equivalent call inferred; original call site unknown

		if thread ~= nil then
			task.cancel(thread)
		end

		thread = task.delay(0.25, function()
			thread = nil
			fireIfChanged(p2)
		end)
	end))
	self._Janitor:Add(component.OnCommitted:Connect(function()
		if not component:IsDragging() and v4 == nil then
			if flag then
				return
			end

			local v6 = v5
			v5 = nil
			VehicleController.AcceptServerValue(v3.changed, v6)

			if typeof(v6) == "number" then
				component:SetValue(v6)
			end
		end
	end))

	if v3.getInitial ~= nil or v3.getMax ~= nil then
		self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p2)
			if p2 ~= VehicleController.GetCurrentDrivingVehicleUuid() then
				return
			end

			if v3.getMax ~= nil then
				local max = v3.getMax()

				if typeof(max) == "number" then
					component.Instance:SetAttribute("Max", max)
				end
			end

			if v3.getInitial ~= nil then
				local initial = v3.getInitial()

				if typeof(initial) == "number" then
					component:SetValue(initial)
					value = component:GetValue()
				end
			end
		end))
	end

	self._Janitor:Add(v3.changed:Connect(function(p2: string, value2: number)
		if p2 ~= VehicleController.GetCurrentDrivingVehicleUuid() or typeof(value2) ~= "number" or (component:IsDragging() or v4 ~= nil) then
			return
		end

		if value2 == component:GetValue() then
			return
		end

		component:SetValue(value2)
	end))

	if v3.watchMax == true and v3.getMax ~= nil then
		local function refreshMax()
			local max = v3.getMax()

			if typeof(max) ~= "number" then
				return
			end

			component.Instance:SetAttribute("Max", max)
			component:SetValue(component:GetValue())
		end

		self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(refreshMax))
		self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(refreshMax))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v