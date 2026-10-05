local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Trove = require(packages:WaitForChild("Trove"))
local Component = require(packages:WaitForChild("Component"))
local v = Component.new({
	Tag = "Kraken Pool"
})

function v:Construct()
	self.trove = Trove.new()
	self.isOnRegion = nil

	if self.Instance.Name ~= "Kraken Pool" then
		self.trove:Add(RunService.RenderStepped:Connect(function()
			local character = game.Players.LocalPlayer.Character
			local pivot = character and character:GetPivot() or CFrame.new()
			local isOnRegion = (self.Instance.Position - pivot.Position).Magnitude <= 200

			if self.isOnRegion ~= isOnRegion then
				self.isOnRegion = isOnRegion
				workspace.Terrain.WaterColor = self.isOnRegion and Color3.new() or Color3.fromRGB(60, 66, 85)
				workspace.Terrain.WaterReflectance = self.isOnRegion and 0 or 0.4
				workspace.Terrain.WaterTransparency = self.isOnRegion and 0.1 or 0.45
			end
		end))
	end
end

function v.Start(_) end

function v.Stop(p)
	p.trove:Destroy()
	workspace.Terrain.WaterColor = Color3.fromRGB(60, 66, 85)
	workspace.Terrain.WaterReflectance = 0.4
	workspace.Terrain.WaterTransparency = 0.45
	setmetatable(p, nil)
end

return v