local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
_G.freezecons = {}
return function(p)
	local target = p.target

	if not _G.freezecons[target] then
		if not target:FindFirstChild("HumanoidRootPart") then
			return
		end

		_G.freezecons[target] = true
		local clone = ReplicatedStorage.Chest.SwordEffect.SoulCane.FreezeIndicator:Clone()
		clone.Parent = target.HumanoidRootPart

		local function getstack()
			local children = {}

			for _, child in pairs(target:GetChildren()) do
				if child.Name == "freezestack" then
					children[#children + 1] = child
				end
			end

			task.delay(10, function()
				table.clear(children)
			end)
			return children
		end

		local function refresh()
			local v = getstack()

			for i = 1, 9 do
				local v2 = clone.Progress["ice" .. i]
				v2.ImageTransparency = 0

				if i - 1 >= #v then
					v2.ImageColor3 = Color3.fromRGB(0, 0, 0)
					v2.ImageTransparency = 0.5
				else
					v2.ImageColor3 = Color3.fromRGB(255, 255, 255)
				end
			end
		end

		while true do
			wait()

			if target == nil or not (target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("freezestack")) then
				break
			end

			refresh()

			if not target:FindFirstChild("freezestack") then
				break
			end
		end

		_G.freezecons[target] = false
		clone:Destroy()
	end
end