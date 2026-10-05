local TweenService = game:GetService("TweenService")
local Tweens = {
	playTween = function(_, p, p2, p3)
		local tween = TweenService:Create(p, p2, p3)
		tween:Play()
		return tween
	end,
	infiniteRotate = function(_, p, p2)
		task.spawn(function()
			local v = nil

			local function rotationLoop()
				p.Rotation = -180
				v = TweenService:Create(p, p2, {
					Rotation = 180
				})
				v:Play()
				task.wait(p2.Time)
				v:Destroy()
			end

			while p.Parent ~= nil do
				rotationLoop()
			end
		end)
	end,
	hasProperty = function(self, p, p2)
		local success, _ = pcall(function()
			local _ = p[p2]
		end)
		return success
	end
}

function Tweens.saveInitials(_, folder, items, p)
	if folder:GetAttribute("InitialPropertiesSaved") then
		return
	end

	for _, descendant in pairs(folder:GetDescendants()) do
		if not (descendant:IsA("GuiObject") or descendant:IsA("UIGradient")) then
			continue
		end

		for _, item in pairs(items) do
			if not Tweens:hasProperty(descendant, item) then
				continue
			end

			local v = descendant[item]

			if typeof(v) == "UDim2" then
				descendant:SetAttribute(p .. item .. "_X_Scale", v.X.Scale)
				descendant:SetAttribute(p .. item .. "_X_Offset", v.X.Offset)
				descendant:SetAttribute(p .. item .. "_Y_Scale", v.Y.Scale)
				descendant:SetAttribute(p .. item .. "_Y_Offset", v.Y.Offset)
			elseif typeof(v) == "Vector2" then
				descendant:SetAttribute(p .. item .. "_X", v.X)
				descendant:SetAttribute(p .. item .. "_Y", v.Y)
			else
				descendant:SetAttribute(p .. item, v)
			end
		end
	end

	folder:SetAttribute("InitialPropertiesSaved", true)
end

function Tweens.restoreInitials(_, folder, items, p)
	for _, descendant in pairs(folder:GetDescendants()) do
		if not (descendant:IsA("GuiObject") or descendant:IsA("UIGradient")) then
			continue
		end

		for _, item in pairs(items) do
			local attribute = descendant:GetAttribute(p .. item .. "_X_Scale")

			if attribute == nil then
				if descendant:GetAttribute(p .. item .. "_X") == nil then
					local attribute2 = descendant:GetAttribute(p .. item)

					if Tweens:hasProperty(descendant, item) and attribute2 ~= nil then
						descendant[item] = attribute2
					end
				else
					local attribute2 = descendant:GetAttribute(p .. item .. "_X")
					local attribute3 = descendant:GetAttribute(p .. item .. "_Y")

					if Tweens:hasProperty(descendant, item) then
						descendant[item] = Vector2.new(attribute2, attribute3)
					end
				end
			else
				local attribute2 = descendant:GetAttribute(p .. item .. "_X_Offset")
				local attribute3 = descendant:GetAttribute(p .. item .. "_Y_Scale")
				local attribute4 = descendant:GetAttribute(p .. item .. "_Y_Offset")

				if Tweens:hasProperty(descendant, item) then
					descendant[item] = UDim2.new(attribute, attribute2, attribute3, attribute4)
				end
			end
		end
	end
end

return Tweens