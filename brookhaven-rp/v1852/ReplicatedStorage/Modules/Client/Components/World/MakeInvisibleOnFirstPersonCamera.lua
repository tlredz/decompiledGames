local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "MakeInvisibleOnFirstPersonCamera"
})

local function characterAdded(p, character)
	local head = character:WaitForChild("Head")

	if head == nil then
		return
	end

	p._characterJanitor:Add(head:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
		if not p.Instance:IsDescendantOf(character) then
			return
		end

		if head.LocalTransparencyModifier > 0 then
			if p.Instance:IsA("BasePart") or p.Instance:IsA("MeshPart") then
				p.Instance.Transparency = 1
			elseif p.Instance:IsA("GuiObject") then
				p.Instance.Visible = false
			end
		elseif p.Instance:IsA("BasePart") or p.Instance:IsA("MeshPart") then
			p.Instance.Transparency = 0
		elseif p.Instance:IsA("GuiObject") then
			p.Instance.Visible = true
		end
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function characterRemoving(p, _)
	p._characterJanitor:Cleanup()
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._characterJanitor = Janitor.new()
end

function v:Start()
	local localPlayer = Players.LocalPlayer
	self._Janitor:Add(localPlayer.CharacterAdded:Connect(function(character)
		characterAdded(self, character)
	end))
	self._Janitor:Add(localPlayer.CharacterRemoving:Connect(function(_)
		characterRemoving(self) -- equivalent call inferred; original call site unknown
	end))

	if localPlayer.Character then
		characterAdded(self, localPlayer.Character)
	end
end

function v:Stop()
	self._Janitor:Destroy()
	self._characterJanitor:Destroy()
end

return v