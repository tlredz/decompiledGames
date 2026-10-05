local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "DeckGunUI"
})
local v2 = {
	Off = 1,
	Wide = 2,
	Narrow = 3
}

function v:Construct()
	self._Janitor = Janitor.new()
	self.Activated = Signal.new()
end

function v:Start()
	for _, guiObject in self.Instance.Buttons:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local v3 = guiObject
		self._Janitor:Add(guiObject.Activated:Connect(function()
			local v4 = v2[v3.Name]

			if v4 then
				self.Activated:Fire(v4)
			end
		end))
	end

	self:SetWaterType(1)
end

function v:SetWaterType(p2: number)
	for _, child in self.Instance.Buttons:GetChildren() do
		if p2 == v2[child.Name] then
			child:AddTag("Checked")
		else
			child:RemoveTag("Checked")
		end
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v