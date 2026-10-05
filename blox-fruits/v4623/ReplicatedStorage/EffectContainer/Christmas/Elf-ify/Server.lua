local FX = require(game.ReplicatedStorage.FX)
local christmas = FX:WaitForChild("Christmas")
local v = {
	Head = true,
	LowerTorso = true,
	UpperTorso = true,
	LeftUpperArm = true,
	RightUpperArm = true,
	LeftLowerArm = true,
	RightLowerArm = true,
	LeftLowerLeg = true,
	RightLowerLeg = true,
	LeftUpperLeg = true,
	RightUpperLeg = true,
	LeftHand = true,
	RightHand = true,
	LeftFoot = true,
	RightFoot = true
}
return function(p)
	local root = p.Root
	local parent = root.Parent

	if not root then
		_G.TestGameWarn("Root not found?")
	end

	local humanoid = root.Parent:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		_G.TestGameWarn("Humanoid not found?")
	end

	local function addAccessory(object, childName)
		local child = christmas:FindFirstChild(childName)

		if not child then
			warn("Accessory not found")
			return
		end

		local clone = child:Clone()
		object:AddAccessory(clone)
		return clone
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setShirtAndPants(parent2, _, _)
		local proxy_Shirt = parent2:FindFirstChild("Proxy_Shirt")
		local proxy_Pants = parent2:FindFirstChild("Proxy_Pants")

		if proxy_Shirt then
			proxy_Shirt:SetAttribute("ShirtTemplate", "http://www.roblox.com/asset/?id=195649229")
		end

		if proxy_Pants then
			proxy_Pants:SetAttribute("PantsTemplate", "http://www.roblox.com/asset/?id=195090417")
		end
	end

	if p.Type == "wenlockEvil" then
		local funnylittlefrog = christmas:FindFirstChild("Funnylittlefrog")

		if funnylittlefrog then
			humanoid:AddAccessory((funnylittlefrog:Clone()))
		else
			warn("Accessory not found")
		end

		local aduriteAntlers = christmas:FindFirstChild("AduriteAntlers")

		if aduriteAntlers then
			humanoid:AddAccessory((aduriteAntlers:Clone()))
		else
			warn("Accessory not found")
		end

		local reindeernose = christmas:FindFirstChild("Reindeernose")

		if reindeernose then
			humanoid:AddAccessory((reindeernose:Clone()))
		else
			warn("Accessory not found")
		end

		local robloxScarf = christmas:FindFirstChild("RobloxScarf")

		if robloxScarf then
			humanoid:AddAccessory((robloxScarf:Clone()))
		else
			warn("Accessory not found")
		end

		root.Parent.Head.face.Texture = "rbxassetid://1016178220"
		setShirtAndPants(parent) -- equivalent call inferred; original call site unknown
	else
		humanoid.DisplayName ..= " [Elf]"
		local head = root.Parent.Head
		local bodyColors = root.Parent:FindFirstChildWhichIsA("BodyColors")

		if bodyColors then
			bodyColors.HeadColor = BrickColor.new("Olivine")
			bodyColors.LeftArmColor = BrickColor.new("Olivine")
			bodyColors.LeftLegColor = BrickColor.new("Olivine")
			bodyColors.RightArmColor = BrickColor.new("Olivine")
			bodyColors.RightLegColor = BrickColor.new("Olivine")
			bodyColors.TorsoColor = BrickColor.new("Olivine")

			for childName in pairs(v) do
				if root.Parent:FindFirstChild(childName) then
					root.Parent[childName].BrickColor = BrickColor.new("Olivine")
				end
			end
		end

		local elfEars = christmas:FindFirstChild("Elf Ears")
		local clone

		if elfEars then
			clone = elfEars:Clone()
			humanoid:AddAccessory(clone)
		else
			warn("Accessory not found")
		end

		clone.Handle.Color = head.Color
	end

	parent:SetAttribute("Elf", true)
end