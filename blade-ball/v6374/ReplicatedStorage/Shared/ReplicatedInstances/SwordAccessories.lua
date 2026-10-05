local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3("@game/ReplicatedStorage/Common/Utils/Utilities/Physics")
local v2 = require3("@game/ReplicatedStorage/Shared/ReplicatedInstancesUtils")
local v3 = require3("@game/ReplicatedStorage/Shared/AttrGeneration")
local v4 = require3("@game/ReplicatedStorage/Common/Logger")
local v5 = require3(script.Parent)
local scope = v3.scope("Swords")
local scope2 = v4.namespace("RepInst"):scope("SwordAccessories")

if RunService:IsServer() then
	-- equivalent calls inferred from this helper; original call sites unknown
	local function registerAccessory(child)
		local clone = table.clone(child:GetAttributes())
		clone.Name = child.Name
		v5:AddObjectToCollection("SwordAccessories", child.Name, child, clone)
	end

	for _, child in ServerStorage.Misc.SwordAccessories:GetChildren() do
		if child.Name == ".Temp" then
			for _, child2 in child:GetChildren() do
				if child2.Name == "Ignore" then
					continue
				end

				registerAccessory(child2) -- equivalent call inferred; original call site unknown
			end
		else
			registerAccessory(child) -- equivalent call inferred; original call site unknown
		end
	end
end

local instanceReplicatorFor = v5.createInstanceReplicatorFor("SwordAccessories")

function instanceReplicatorFor:GetInstance(p: string)
	return v2.getInstance("SwordAccessories", p)
end

function instanceReplicatorFor:GetAccessory(p: string)
	return self:GetCollection()[p]
end

function instanceReplicatorFor:ResolveState(instance, p: string, data, flag: boolean?)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
	local v6 = data.AccessoryToggleable and true or false
	local isInverted = data.InvertedAccessory and true or false
	local v8

	if playerFromCharacter then
		v8 = playerFromCharacter:GetAttribute("ShowSwordAccessory") ~= false
	else
		v8 = instance:GetAttribute("ShowSwordAccessory") ~= false
	end

	local isToggledOn

	if instance:GetAttribute("InOverdriveMech") then
		isToggledOn = false
	else
		isToggledOn = not v6 or v8
	end

	local v10

	if isToggledOn then
		v10 = data.AccessoryOnVariant
	else
		v10 = data.AccessoryOffVariant
	end

	local variantName = v10 or p
	local accessory

	if not flag then
		accessory = self:GetAccessory(variantName) or self:GetAccessory(p)
	end

	if accessory then
		return {
			HasAccessory = true,
			IsToggledOn = isToggledOn,
			ShouldCreate = isInverted or data.AccessoryOffVariant ~= nil or isToggledOn,
			IsInverted = isInverted,
			VariantName = accessory.Name,
			Info = accessory
		}
	end

	return {
		HasAccessory = false,
		IsToggledOn = false,
		ShouldCreate = false,
		IsInverted = false,
		VariantName = variantName,
		Info = nil
	}
end

function instanceReplicatorFor:EquipAccessoryTo(instance, childName: string, accessory: string, p2: number?)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
	scope2:info(playerFromCharacter, (`Equipping accessory {accessory} for {childName}`))
	local v6 = p2 or scope.begin(instance, {
		sword = childName,
		accessory = accessory
	})

	if not v6 then
		scope2:info(playerFromCharacter, "Same sword or accessory state already equipping, nothing to do")
		return
	end

	if not self:GetAccessory(accessory) then
		scope2:warn(playerFromCharacter, (`Accessory {accessory} not found`))
		return nil
	end

	for _, v7 in instance:QueryDescendants("[$_swordAccessory]") do
		v7:Destroy()
	end

	local instance2 = v.Instance("Folder", {
		Name = "SwordAccessories",
		["$_swordAccessory"] = true,
		["$Seed"] = Random.new():NextNumber(0, 100)
	}, instance)
	local instance3 = self:GetInstance(accessory)

	if scope.isCurrent(instance, v6) and instance2.Parent == instance then
		v.RigModelToChar(instance3, instance, instance2, true)

		if childName == "Cherub" then
			local child = instance:FindFirstChild("Cherub")
			local sord = child and child:FindFirstChild("sord")

			if sord and sord:IsA("BasePart") then
				sord.Transparency = 1
			end
		end

		for _, folder in instance2:GetChildren() do
			local v8 = false

			for _, animationController in folder:GetDescendants() do
				if not animationController:IsA("AnimationController") then
					continue
				end

				v8 = true

				if animationController:FindFirstChildOfClass("Animator") then
					continue
				end

				local animator = Instance.new("Animator")
				animator.Parent = animationController
			end

			if not (childName == "Ryuzakura Katana" and v8) then
				continue
			end

			folder:AddTag("RyuzakuraKatanaIdle")
			break
		end

		scope2:info(playerFromCharacter, (`Equipped accessory {accessory}`))
		return instance2
	else
		scope2:info(playerFromCharacter, (`Unequipped accessory {childName} before it could load`))

		if instance2.Parent == instance then
			instance2:Destroy()
		end

		instance3:Destroy()
	end
end

function instanceReplicatorFor.UpdateHeadless(_, instance, p, headless: boolean, p2: number)
	local head = instance:FindFirstChild("Head")

	if not head then
		return
	end

	if p == nil then
		headless = false
	elseif p.UsesHeadless ~= true then
		headless = false
	end

	if (head:GetAttribute("Headless") == true or head.Transparency == 1) == headless then
		return
	end

	task.spawn(function()
		repeat
			task.wait()
		until instance:GetAttribute("AppearanceLoaded") or not scope.isCurrent(instance, p2)

		if not scope.isCurrent(instance, p2) then
			return
		end

		head.Transparency = headless and 1 or 0
		head:SetAttribute("Headless", headless)
	end)
end

function script.GetInstance.OnInvoke(p: string)
	return instanceReplicatorFor:GetInstance(p)
end

return instanceReplicatorFor