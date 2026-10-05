local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "PropertyDiscoRoomMusic"
})

local function collectButtons(instance)
	local result = {}

	if instance == nil then
		return result
	end

	if instance:IsA("ObjectValue") then
		if instance.Value ~= nil then
			table.insert(result, instance.Value)
			return result
		end
	elseif instance:IsA("Folder") then
		for _, objectValue in instance:GetChildren() do
			if objectValue:IsA("ObjectValue") and objectValue.Value ~= nil then
				table.insert(result, objectValue.Value)
			end
		end
	end

	return result
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.isInside = false
	self.sound = self.Instance
end

function v:_SetInside(isInside: boolean)
	if self.isInside == isInside then
		return
	end

	self.isInside = isInside
	self:_Refresh()
end

function v:_ConnectButtons(p, flag: boolean)
	for _, v2 in collectButtons(p) do
		local clickDetector = v2:FindFirstChildWhichIsA("ClickDetector")

		if clickDetector ~= nil then
			self._Janitor:Add(clickDetector.MouseClick:Connect(function(p2)
				if p2 ~= localPlayer then
					return
				end

				self:_SetInside(flag)
			end))
		end
	end
end

function v:_SyncTimePosition()
	local timeLength = self.sound.TimeLength

	if timeLength <= 0 then
		return
	end

	self.sound.TimePosition = workspace:GetServerTimeNow() % timeLength
end

function v:_Refresh()
	if self.isInside and self.sound:GetAttribute("ShouldPlay") == true then
		if not self.sound.IsPlaying then
			self:_SyncTimePosition()
			self.sound:Play()
		end
	elseif self.sound.IsPlaying then
		self.sound:Pause()
	end
end

function v:Start()
	self:_ConnectButtons(self.Instance:FindFirstChild("EntryButton"), true)
	self:_ConnectButtons(self.Instance:FindFirstChild("ExitButton"), false)
	self._Janitor:Add(localPlayer.CharacterRemoving:Connect(function()
		self:_SetInside(false)
	end))
	self._Janitor:Add(self.sound:GetAttributeChangedSignal("ShouldPlay"):Connect(function()
		self:_Refresh()
	end))
	self:_Refresh()
end

function v:Stop()
	if self.sound.IsPlaying then
		self.sound:Pause()
	end

	self._Janitor:Destroy()
end

return v