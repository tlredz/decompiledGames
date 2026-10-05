local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
return function()
	local parent = script.Parent
	local NexusInstance = require(parent:WaitForChild("Packages"):WaitForChild("NexusInstance"))
	local v = {
		Registered = NexusInstance.TypedEvent.new(),
		Register = function(self, p2: string, p3)
			if self[p2] ~= nil then
				error((`API already registered: {p2}`))
			end

			self[p2] = p3
			self.Registered:Fire(p2)
		end,
		WaitFor = function(p, p2: string)
			while not p[p2] do
				p.Registered:Wait()
			end

			return p[p2]
		end,
		OnRegistered = function(p, p2: string, callback)
			if p[p2] then
				task.spawn(function()
					callback(p[p2])
				end)
			else
				p.Registered:Connect(function(p3)
					if p2 ~= p3 then
						return
					end

					callback(p[p2])
				end)
			end
		end
	}

	if RunService:IsClient() then
		task.defer(function()
			local CameraService = require(parent:WaitForChild("State"):WaitForChild("CameraService"))
			local instance = CameraService.GetInstance()
			v:Register("Camera", {
				SetActiveCamera = function(self, p: string)
					instance:SetActiveCamera(p)
				end,
				GetActiveCamera = function(_)
					return instance.ActiveCamera
				end
			})
			local v2 = {}
			local ControlService = require(parent:WaitForChild("State"):WaitForChild("ControlService"))
			local instance2 = ControlService.GetInstance()
			v:Register("Controller", {
				SetActiveController = function(self, p: string)
					instance2:SetActiveController(p)
				end,
				GetActiveController = function(_)
					return instance2.ActiveController
				end,
				SetControllerInputEnabled = function(self, p, flag: boolean)
					if p ~= Enum.UserCFrame.LeftHand and p ~= Enum.UserCFrame.RightHand then
						error((`The following UserCFrame is invalid and can't be disabled: {p}`))
					end

					v2[p] = flag ~= false
				end,
				EnableControllerInput = function(self, p)
					self:SetControllerInputEnabled(p, true)
				end,
				DisableControllerInput = function(self, p)
					self:SetControllerInputEnabled(p, false)
				end,
				IsControllerInputEnabled = function(_, p)
					if p ~= Enum.UserCFrame.LeftHand and p ~= Enum.UserCFrame.RightHand then
						error((`The following UserCFrame is invalid and can't be disabled: {p}`))
					end

					return v2[p] ~= false
				end
			})
			local VRInputService = require(parent:WaitForChild("State"):WaitForChild("VRInputService"))
			local instance3 = VRInputService.GetInstance()
			v:Register("Input", {
				Recentered = instance3.Recentered,
				EyeLevelSet = instance3.EyeLevelSet,
				Recenter = function(self)
					instance3:Recenter()
				end,
				SetEyeLevel = function(self)
					instance3:SetEyeLevel()
				end
			})
			local v4 = {}

			local function GetMainMenu()
				if not v4.Enabled then
					error("Menu API is not enabled for non-VR players. Check Api.Menu.Enabled before calling.")
				end

				local MainMenu = require(parent:WaitForChild("UI"):WaitForChild("MainMenu"))
				return MainMenu.GetInstance()
			end

			if UserInputService.VREnabled then
				v4.Enabled = true
			else
				v4.Enabled = false
				UserInputService:GetPropertyChangedSignal("VREnabled"):Connect(function()
					v4.Enabled = UserInputService.VREnabled
				end)
			end

			function v4:CreateView(...)
				if not v4.Enabled then
					error("Menu API is not enabled for non-VR players. Check Api.Menu.Enabled before calling.")
				end

				local MainMenu = require(parent:WaitForChild("UI"):WaitForChild("MainMenu"))
				return MainMenu.GetInstance():CreateView(...)
			end

			function v4.IsOpen()
				if not v4.Enabled then
					error("Menu API is not enabled for non-VR players. Check Api.Menu.Enabled before calling.")
				end

				local MainMenu = require(parent:WaitForChild("UI"):WaitForChild("MainMenu"))
				return MainMenu.GetInstance().ScreenGui.Enabled
			end

			function v4:Open()
				if self:IsOpen() then
					return
				end

				if not v4.Enabled then
					error("Menu API is not enabled for non-VR players. Check Api.Menu.Enabled before calling.")
				end

				local MainMenu = require(parent:WaitForChild("UI"):WaitForChild("MainMenu"))
				MainMenu.GetInstance():Toggle()
			end

			function v4:Close()
				if not self:IsOpen() then
					return
				end

				if not v4.Enabled then
					error("Menu API is not enabled for non-VR players. Check Api.Menu.Enabled before calling.")
				end

				local MainMenu = require(parent:WaitForChild("UI"):WaitForChild("MainMenu"))
				MainMenu.GetInstance():Toggle()
			end

			v:Register("Menu", v4)
			local Settings = require(parent:WaitForChild("State"):WaitForChild("Settings"))
			local instance4 = Settings.GetInstance()
			v:Register("Settings", {
				GetSetting = function(self, p: string)
					return instance4:GetSetting(p)
				end,
				SetSetting = function(self, p: string, p2)
					instance4:SetSetting(p, p2)
				end,
				GetSettingsChangedSignal = function(self, p: string)
					return instance4:GetSettingsChangedSignal(p)
				end
			})
		end)
	end

	return v
end