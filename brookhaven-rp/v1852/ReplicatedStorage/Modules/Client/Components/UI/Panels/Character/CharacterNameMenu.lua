local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local UIColorPicker = require(ReplicatedStorage.Modules.Client.Components.UI.UIColorPicker)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local rPNameTextRemote = LegacyGame8Settings.RPNameTextRemote
local rPNameColorRemote = LegacyGame8Settings.RPNameColorRemote
local v = Component.new({
	Tag = "CharacterNameMenu"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:_SetupTextBoxes(folder)
	local v2 = false

	for _, textBox in folder:GetDescendants() do
		if not textBox:IsA("TextBox") then
			continue
		end

		local v3 = textBox
		self._Janitor:Add(textBox.FocusLost:Connect(function()
			if v2 == true then
				return
			end

			v2 = true

			if v3.Name == "RPMainName" then
				rPNameTextRemote:FireServer("RolePlayName", v3.Text)
			elseif v3.Name == "RPMainBio" then
				rPNameTextRemote:FireServer("RolePlayBio", v3.Text)
			end

			task.wait(0.3)
			v2 = false
		end))
	end
end

function v:_SetupColorPreview(instance)
	local finalColorName = instance:WaitForChild("FinalColorName")
	local finalColorBio = instance:WaitForChild("FinalColorBio")
	local component = ComponentUtil.GetComponentFromInstance(instance, UIColorPicker)
	local finalColorButton = component.finalColorButton

	if finalColorButton == nil then
		finalColorButton = instance:FindFirstChild("FinalColorButton", true)
	end

	assert(finalColorButton ~= nil, "CharacterNameMenu expected a FinalColorButton inside the color picker")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updatePreview()
		local backgroundColor3 = finalColorButton.BackgroundColor3
		finalColorName.BackgroundColor3 = backgroundColor3
		finalColorBio.BackgroundColor3 = backgroundColor3
	end

	updatePreview() -- equivalent call inferred; original call site unknown
	self._Janitor:Add(finalColorButton:GetPropertyChangedSignal("BackgroundColor3"):Connect(updatePreview))
	self._Janitor:Add(component.OnColorPicked:Connect(updatePreview))
	local maid = Janitor.new()
	self._Janitor:Add(maid)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setRenderSteppedEnabled(visible: boolean)
		maid:Cleanup()

		if visible == true then
			maid:Add(RunService.RenderStepped:Connect(updatePreview), "Disconnect")
		end
	end

	setRenderSteppedEnabled(self.Instance.Visible) -- equivalent call inferred; original call site unknown
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		setRenderSteppedEnabled(self.Instance.Visible) -- equivalent call inferred; original call site unknown
	end))
	local v2 = false
	self._Janitor:Add(finalColorName.MouseButton1Click:Connect(function()
		if v2 == true then
			return
		end

		v2 = true
		rPNameColorRemote:FireServer("PickingRPNameColor", finalColorButton.BackgroundColor3)
		task.wait(1)
		v2 = false
	end))
	local v3 = false
	self._Janitor:Add(finalColorBio.MouseButton1Click:Connect(function()
		if v3 == true then
			return
		end

		v3 = true
		rPNameColorRemote:FireServer("PickingRPBioColor", finalColorButton.BackgroundColor3)
		task.wait(1)
		v3 = false
	end))
end

function v:_SetupVipRainbow(instance)
	local v2 = {
		{
			instance = instance:WaitForChild("VIPColor1"),
			featureId = "VIPNameColor1",
			label = "bio effect 1",
			tag = "Rainbow Name",
			time = 20,
			range = 10
		},
		{
			instance = instance:WaitForChild("VIPColor2"),
			featureId = "VIPNameColor2",
			label = "bio effect 2",
			tag = "Rainbow Name",
			time = 1,
			range = 1
		},
		{
			instance = instance:WaitForChild("VIPColor3"),
			featureId = "VIPNameColor3",
			label = "bio effect 3",
			tag = "Rainbow Name",
			time = 2,
			range = 10
		}
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearOtherCheckmarks(p2)
		for _, v3 in v2 do
			if v3 ~= p2 then
				v3.instance.GreenCheckMark.Visible = false
			end
		end
	end

	for _, v3 in v2 do
		local instance2 = v3.instance
		local v4 = false
		local v5 = v3
		self._Janitor:Add(instance2.MouseButton1Click:Connect(function()
			if v4 == true then
				return
			end

			v4 = true

			if UnlockableController.IsFeatureUnlocked(v5.featureId, Gamepasses.VIP) then
				if instance2.GreenCheckMark.Visible == true then
					instance2.GreenCheckMark.Visible = false
					rPNameTextRemote:FireServer("OffVIPNameColor1")
				else
					clearOtherCheckmarks(v5) -- equivalent call inferred; original call site unknown
					instance2.GreenCheckMark.Visible = true
					rPNameTextRemote:FireServer("OnVIPNameColor1", v5.time, v5.range)
				end
			else
				GamepassController.Show(Gamepasses.VIP, nil, v5.label, nil, {
					id = v5.featureId,
					icon = instance2.Image
				}, nil, "Avatar Settings", v5.tag, function()
					if instance2.Parent == nil or not self.Instance.Visible then
						return
					end

					if not instance2.GreenCheckMark.Visible then
						clearOtherCheckmarks(v5) -- equivalent call inferred; original call site unknown
						instance2.GreenCheckMark.Visible = true
						rPNameTextRemote:FireServer("OnVIPNameColor1", v5.time, v5.range)
					end
				end)
			end

			task.wait(0.5)
			v4 = false
		end))
	end

	self._Janitor:Add(rPNameTextRemote.OnClientEvent:Connect(function(p2)
		if p2 == "ResetPlayerRainBow1" then
			rPNameTextRemote:FireServer("OnVIPNameColor1", 1, 1)
		elseif p2 == "ResetPlayerRainBow2" then
			rPNameTextRemote:FireServer("OnVIPNameColor1", 2, 10)
		elseif p2 == "ResetPlayerRainBow20" then
			rPNameTextRemote:FireServer("OnVIPNameColor1", 20, 10)
		end
	end))
end

function v:Start()
	local scrollingFrameName = self.Instance:WaitForChild("Catalog"):WaitForChild("Container"):WaitForChild("ScrollingFrameName")
	local nameBioFrame = scrollingFrameName:WaitForChild("NameBox"):WaitForChild("NameBioFrame")
	self:_SetupTextBoxes(scrollingFrameName)
	self:_SetupColorPreview(nameBioFrame)
	self:_SetupVipRainbow(nameBioFrame)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v