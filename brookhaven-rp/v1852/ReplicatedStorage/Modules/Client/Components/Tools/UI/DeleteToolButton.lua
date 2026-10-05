local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "DeleteToolButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	if self.Instance:IsA("ImageButton") then
		self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
			local character = Players.LocalPlayer.Character

			if character == nil then
				return
			end

			local tool = character:FindFirstChildOfClass("Tool")

			if tool == nil then
				return
			end

			Remotes.fireServerComponent(tool, "QuickDelete")
		end))
	else
		warn("DeleteToolButton component not on Sound!")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v