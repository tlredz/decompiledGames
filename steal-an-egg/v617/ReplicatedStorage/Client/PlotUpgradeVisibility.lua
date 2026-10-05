local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlotState = require(ReplicatedStorage.Client.PlotState)
local t = require(ReplicatedStorage.Packages.t)

local function paintSubtree(folder, enabled: boolean)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.LocalTransparencyModifier = enabled and 0 or 1
		elseif descendant:IsA("SurfaceGui") then
			descendant.Enabled = enabled
		elseif descendant:IsA("BillboardGui") and not enabled then
			descendant.Enabled = false
		elseif descendant:IsA("BillboardGui") and descendant.Name ~= "CanUpgrade" then
			descendant.Enabled = true
		end
	end
end

return {
	Apply = function(p: string, flag: boolean?)
		t.strict(t.string)(p)
		t.strict(t.optional(t.boolean))(flag)
		local folder = PlotState.ResolveFolder()
		local localSlot = PlotState.ResolveLocalSlot()
		local v

		if localSlot ~= nil then
			v = tostring(localSlot)
		end

		for _, v2 in folder == nil and {} or folder:GetDescendants() do
			local parent = v2.Parent

			if v2.Name == p and parent ~= nil then
				paintSubtree(v2, v ~= nil and parent.Name == v and flag ~= false)
			end
		end
	end
}