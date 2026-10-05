local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
game:GetService("TweenService")
local Component = require(ReplicatedStorage.packages.Component)
local Trove = require(ReplicatedStorage.packages.Trove)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local utils = ReplicatedStorage.shared.utils
require(utils.assets)
local GeneralUtils = require(utils.GeneralUtils)
local fx = require(ReplicatedStorage.shared.modules.fx)
local DataController = require(legacyControllers.DataController)
local cragCrabAltar = Component.new({
	Tag = "CragCrabAltar",
	Ancestors = { workspace }
})

function cragCrabAltar:Construct()
	self.Trove = Trove.new()
end

function cragCrabAltar.Start(p)
	local instance = p.Instance
	local pearlIndicators = instance:WaitForChild("Pearl Indicators")

	local function RegisterIndicator(parent)
		if parent:FindFirstChildOfClass("ClickDetector") then
			return
		end

		if not parent:GetAttribute("OriginalColor") then
			parent:SetAttribute("OriginalColor", parent.Color)
		end

		local v2 = p.Trove:Add(Instance.new("ClickDetector"))
		v2.MouseClick:Connect(function()
			ReplicatedStorage.events.anno_localthought:Fire((`This needs <b><font color="#{parent:GetAttribute("OriginalColor"):ToHex()}">{parent.Name}</font></b>`))
		end)
		v2.Parent = parent
	end

	for _, child in pearlIndicators:GetChildren() do
		task.spawn(RegisterIndicator, child)
	end

	pearlIndicators.ChildAdded:Connect(RegisterIndicator)

	local function UpdatePearlsPlaced(list, p2)
		if not list then
			return
		end

		for _, childName in list do
			local child = pearlIndicators:FindFirstChild(childName)

			if child then
				if p2 == nil then
					child.Material = Enum.Material.Neon
					child.Transparency = 0.35
				else
					fx:PlaySound(script.Place, child)

					if not child:GetAttribute("OriginalColor") then
						child:SetAttribute("OriginalColor", child.Color)
					end

					local originalColor = child:GetAttribute("OriginalColor")
					child.Material = Enum.Material.Neon
					child.Color = Color3.fromRGB(255, 255, 255)
					child.Transparency = 0
					GeneralUtils.fastTween(child, TweenInfo.new(1.5), {
						Color = originalColor,
						Transparency = 0.35
					})
				end
			else
				warn((`[RupturerController] No indicator for pearl "{childName}" found`))
			end
		end

		if #list >= #pearlIndicators:GetChildren() then
			local proximityPrompt = instance.Prompt:FindFirstChildOfClass("ProximityPrompt")
			proximityPrompt.Enabled = false
		end
	end

	p.Trove:Add(DataController.PlayerDataReplicator:Observe({ "ScoriaReach", "PearlsPlaced" }, UpdatePearlsPlaced))
end

function cragCrabAltar.Stop(p)
	p.Trove:Clean()
end

return {
	CragCrabAltar = cragCrabAltar,
	Start = function(_) end
}