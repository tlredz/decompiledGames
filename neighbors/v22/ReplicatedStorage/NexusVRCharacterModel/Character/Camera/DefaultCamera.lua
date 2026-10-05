local v = {
	[Enum.AccessoryType.Hat] = true,
	[Enum.AccessoryType.Hair] = true,
	[Enum.AccessoryType.Face] = true,
	[Enum.AccessoryType.Eyebrow] = true,
	[Enum.AccessoryType.Eyelash] = true
}
local Players = game:GetService("Players")
local VRService = game:GetService("VRService")
local parent = script.Parent.Parent.Parent
local CommonCamera = require(parent:WaitForChild("Character"):WaitForChild("Camera"):WaitForChild("CommonCamera"))
local Settings = require(parent:WaitForChild("State"):WaitForChild("Settings"))
local instance = Settings.GetInstance()
local DefaultCamera = {}
DefaultCamera.__index = DefaultCamera
setmetatable(DefaultCamera, CommonCamera)

function DefaultCamera.ShouldHidePart(instance2)
	local parent2 = instance2.Parent

	if parent2 then
		if parent2:IsA("Accessory") then
			return v[parent2.AccessoryType] or false
		end

		return not parent2:IsA("Model") and not parent2:IsA("Tool")
	else
		return not instance2:FindFirstChildWhichIsA("WrapLayer")
	end
end

function DefaultCamera.new()
	return (setmetatable(CommonCamera.new(), DefaultCamera))
end

function DefaultCamera:Enable()
	local connections = {}
	self.TransparencyEvents = connections

	if Players.LocalPlayer.Character then
		local setting = instance:GetSetting("Appearance.LocalCharacterTransparency")

		if setting == 0.5 then
			setting = 0.501
		elseif setting < 0.5 then
			warn("Values of <0.5 with Appearance.LocalCharacterTransparency are currently known to cause black screen issues. This will hopefully be resolved by Roblox in a future update: https://devforum.roblox.com/t/vr-screen-becomes-black-due-to-non-transparent-character/2215099")
		end

		table.insert(connections, Players.LocalPlayer.Character.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") then
				local localTransparencyModifier = part:FindFirstAncestorOfClass("Tool") and 0 or DefaultCamera.ShouldHidePart(part) and 1 or setting
				part.LocalTransparencyModifier = localTransparencyModifier
				table.insert(connections, part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
					part.LocalTransparencyModifier = localTransparencyModifier
				end))
			end
		end))

		for _, part in Players.LocalPlayer.Character:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			local localTransparencyModifier = part:FindFirstAncestorOfClass("Tool") and 0 or DefaultCamera.ShouldHidePart(part) and 1 or setting
			part.LocalTransparencyModifier = localTransparencyModifier
			local v4 = part
			table.insert(connections, part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
				v4.LocalTransparencyModifier = localTransparencyModifier
			end))
		end
	end

	table.insert(connections, Players.LocalPlayer:GetPropertyChangedSignal("Character"):Connect(function()
		self:Disable()
		self:Enable()
	end))
	table.insert(
		connections,
		(instance:GetSettingsChangedSignal("Appearance.LocalCharacterTransparency"):Connect(function()
			self:Disable()
			self:Enable()
		end))
	)

	if VRService.AvatarGestures then
		Players.LocalPlayer.CameraMaxZoomDistance = Players.LocalPlayer.CameraMinZoomDistance
	end
end

function DefaultCamera:Disable()
	if self.TransparencyEvents then
		for _, transparencyEvent in self.TransparencyEvents do
			transparencyEvent:Disconnect()
		end

		self.TransparencyEvents = {}
	end

	if Players.LocalPlayer.Character then
		for _, part in Players.LocalPlayer.Character:GetDescendants() do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 0
			end
		end
	end
end

function DefaultCamera.UpdateCamera(object, cframe: CFrame)
	if VRService.AvatarGestures then
		return
	end

	object:SetCFrame(cframe)
end

return DefaultCamera