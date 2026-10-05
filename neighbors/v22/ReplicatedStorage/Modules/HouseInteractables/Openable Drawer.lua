local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(1)
return function(folder)
	local v = BaseInteractable.new()
	local clone = script.Example:Clone()
	clone:PivotTo(folder:GetPivot())
	clone.Parent = folder.Parent
	clone.Name = folder.Name

	local function FindMatchingPart(part)
		for _, descendant in folder:GetDescendants() do
			if descendant.Name == part.Name and descendant.ClassName == part.ClassName then
				return descendant
			end
		end

		return nil
	end

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local part2 = FindMatchingPart(part)

		if not (part2 and part2:IsA("BasePart")) then
			continue
		end

		part.Color = part2.Color
		part.Material = part2.Material
		part.MaterialVariant = part2.MaterialVariant
	end

	folder:Destroy()
	local v2 = {
		Drawer = {
			Joint = clone.Root["Meshes/drawer_drawer.002"],
			Offset = CFrame.new(1.5, 0, 0)
		}
	}
	local v3 = {}

	for k, v4 in v2 do
		v3[k] = {
			C0 = v4.Joint.C0,
			C1 = v4.Joint.C1
		}
	end

	function v.Run(p)
		if p.State then
			for k, v4 in v2 do
				local C0 = v3[k].C0 * v4.Offset
				TweenService:Create(v4.Joint, tweenInfo, {
					C0 = C0
				}):Play()
			end
		else
			for k, v4 in v2 do
				local C0 = v3[k].C0
				TweenService:Create(v4.Joint, tweenInfo, {
					C0 = C0
				}):Play()
			end
		end
	end

	for _, parent in {
		clone["Meshes/drawer_drawer.002"],
		clone["Meshes/drawer_drawer.001"],
		clone["Meshes/drawer_drawer"]
	} do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.Parent = parent
		clickDetector.MaxActivationDistance = 12
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end