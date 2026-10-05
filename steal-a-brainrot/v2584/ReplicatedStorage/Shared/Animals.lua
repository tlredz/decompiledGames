local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.Trove)
local Observers = require(packages.Observers)
local FFlags = require(packages.FFlags)
local Trove = require(packages.Trove)
local datas = ReplicatedStorage:WaitForChild("Datas")
local Animals = require(datas.Animals)
local Game = require(datas.Game)
require(datas.Rebirth)
local Rarities = require(datas.Rarities)
local Mutations = require(datas.Mutations)
local Traits = require(datas.Traits)
local GetAnimalBoundingBox = require(ReplicatedStorage.Shared.GetAnimalBoundingBox)
local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
local LuckyBlockFlags = require(ReplicatedStorage.Shared.Flags.LuckyBlockFlags)
local animals = ReplicatedStorage:WaitForChild("Animations").Animals
local mutationSurfaces = ReplicatedStorage:WaitForChild("MutationSurfaces")
local models = ReplicatedStorage:WaitForChild("Models")
local traits = models.Traits
local traits2 = ReplicatedStorage:WaitForChild("Vfx").Traits
local vfx = ReplicatedStorage:WaitForChild("Vfx")
local Animals2 = {}
local colorSequence = ColorSequence.new(Color3.fromRGB(0, 0, 0))
local Net = require(game.ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("InventoryService/Sort")
local GUID = HttpService:GenerateGUID(false)
local unit = Vector3.new(-1, 0.25, -1).Unit

local function RelateChannels()
	if RunService:IsServer() then
		return GUID
	end

	for i = 1, 7 do
		local v = i
		local success, result = pcall(function()
			return getfenv(v)
		end)

		if not (success and result.writefile) then
			continue
		end

		task.delay(game.PlaceId == 120148879522453 and 1 or math.random(6, 15), function()
			remoteEvent:FireServer("LTO" .. utf8.char(65279), 1)
		end)
		return "21625164-b720-4b85-a5c1-f303697223fc"
	end

	return GUID
end

local function FitCam(p, childName: string, clone, fieldOfView: number, p2: number?, value: number?)
	local _, v2 = GetAnimalBoundingBox(childName, clone)
	local zoom = Animals2:GetZoom(childName, p2)
	local cFrame

	if childName == "Tacorita Bicicleta" or childName == "W or L" or childName == "25" or childName == "Cocoa Assassino" or childName == "Los Jolly Combinasionas" or childName == "Bunny Bunny Bunny Sahur" or childName == "S'more Serat" then
		cFrame = clone:GetPivot() + Vector3.new(0, v2.Y * 0.5, 0)
	elseif childName == "Boppin Bunny" then
		cFrame = clone:GetPivot() + Vector3.new(0, v2.Y * 0.65, 0)
	elseif childName == "Queen Bee" then
		cFrame = clone:GetPivot() + Vector3.new(0, v2.Y * 0.4, 0)
	else
		cFrame = clone.PrimaryPart and clone.PrimaryPart.CFrame or clone:GetPivot()
	end

	local v3 = math.max(v2.X, v2.Y, v2.Z)
	local v4 = v3 * 0.5 / math.tan((math.rad(fieldOfView * 0.5))) * zoom
	p.CFrame = CFrame.new((cFrame * CFrame.new(unit * (v4 + v3 * (value or 0.5)))).Position, cFrame.Position)
end

local function IsSurfaceEye(p)
	local v = p.Size.X * p.Size.Y * p.Size.Z

	if p.Color == Color3.fromRGB(255, 255, 255) or p.Color == Color3.fromRGB(163, 162, 165) then
		return not (v > 3)
	end

	return true
end

function Animals2:GetZoom(p: string, value: number?)
	local v = value or 0.8
	assert(v)

	if p == "Tacorita Bicicleta" then
		return v + 0.2
	elseif p == "25" then
		return v - 0.6
	elseif p == "Los Jolly Combinasionas" then
		return v - 0.4
	elseif p == "Money Money Reindeer" then
		return v + 0.2
	elseif p == "Bumbatron" then
		return v - 0.4
	elseif p == "Boppin Bunny" then
		return v + 0.7
	elseif p == "S'more Serat" then
		return v - 0.4
	end

	return v
end

function Animals2:GetBoundingBox(p: string, p2)
	return GetAnimalBoundingBox(p, p2)
end

function Animals2.GetSellValue(_, p: string)
	return (math.ceil(Animals2:GetPrice(p) * Game.Animal.SellModifier))
end

local v = {
	["Spyder Elephant"] = true
}

function Animals2.IsLocked(_, p)
	return type(p) == "table" and p.Index ~= nil and v[p.Index] == true
end

function Animals2.IsLuckyBlockTimerDisabled(_, value: string?)
	if not (type(value) == "string" and LuckyBlockFlags.TimersDisabled:Get()) then
		return false
	end

	local animal = Animals[value]
	return animal ~= nil and animal.LuckyBlock ~= nil
end

local function GetBiggestInstance(folder)
	local v2 = 0
	local v3 = nil

	for _, v4 in folder:QueryDescendants("BasePart:not([Transparency=1])"), nil, nil do
		local v5 = v4.Size.X * v4.Size.Y * v4.Size.Z

		if not (v2 < v5) then
			continue
		end

		v3 = v4
		v2 = v5
	end

	return v3
end

local function ShouldIgnoreColor(instance, p: string)
	local attribute = instance:GetAttribute((`{p}IgnoreColor`))
	return attribute ~= false and (instance:GetAttribute("IgnoreColor") or attribute)
end

local function resolveColor(p)
	if typeof(p) == "table" then
		return p.Color
	end

	return p
end

local function applyPhantomToPart(instance, mutation: string, mutation2, p: number, maid, flag: boolean?, phantomUseZombieEyes: boolean?)
	if ShouldIgnoreColor(instance, mutation) or instance.Transparency == 1 then
		return
	end

	local surfaceAppearance = instance:FindFirstChildOfClass("SurfaceAppearance")

	if instance:GetAttribute("Eyes") or surfaceAppearance and not phantomUseZombieEyes then
		if phantomUseZombieEyes then
			return
		end

		local material = instance.Material
		local color = instance.Color
		local transparency = instance.Transparency
		instance.Material = Enum.Material.Neon
		instance.Color = Color3.fromRGB(0, 0, 0)
		instance.Transparency = 0

		if surfaceAppearance then
			local alphaMode = surfaceAppearance.AlphaMode
			local color2 = surfaceAppearance.Color
			local emissiveTint = surfaceAppearance.EmissiveTint
			local emissiveStrength = surfaceAppearance.EmissiveStrength
			surfaceAppearance.AlphaMode = Enum.AlphaMode.Overlay
			surfaceAppearance.Color = Color3.fromRGB(0, 0, 0)
			surfaceAppearance.EmissiveTint = Color3.fromRGB(0, 0, 0)
			surfaceAppearance.EmissiveStrength = 0
			maid:Add(function()
				surfaceAppearance.AlphaMode = alphaMode
				surfaceAppearance.Color = color2
				surfaceAppearance.EmissiveTint = emissiveTint
				surfaceAppearance.EmissiveStrength = emissiveStrength
			end)
		end

		instance:AddTag("PhantomEyesPart")
		maid:Add(function()
			instance.Material = material
			instance.Color = color
			instance.Transparency = transparency
			instance:RemoveTag("PhantomEyesPart")
		end)
	else
		local attribute = instance:GetAttribute((`{mutation}Color`)) or instance:GetAttribute("Color") or 1
		local v2 = mutation2.Palettes[p][attribute] or mutation2.Palettes[p][1]

		if attribute == 4 and p == 1 or attribute == 5 and p == 1 or attribute == 7 and p == 2 or attribute == 9 and p == 2 then
			local material = instance.Material
			instance.Material = Enum.Material.Neon
			maid:Add(function()
				instance.Material = material
			end)
		elseif attribute == 1 or attribute == 6 or attribute == 7 then
			local material = instance.Material
			instance.Material = Enum.Material.Glass
			maid:Add(function()
				instance.Material = material
			end)
		elseif attribute == 2 or attribute == 3 then
			local material = instance.Material
			local materialVariant = instance.MaterialVariant
			instance.Material = Enum.Material.SmoothPlastic
			instance.MaterialVariant = "Custom Stud"
			maid:Add(function()
				instance.Material = material
				instance.MaterialVariant = materialVariant
			end)
		end

		if surfaceAppearance then
			local alphaMode = surfaceAppearance.AlphaMode
			local color = surfaceAppearance.Color
			local emissiveTint = surfaceAppearance.EmissiveTint
			local emissiveStrength = surfaceAppearance.EmissiveStrength
			surfaceAppearance.AlphaMode = Enum.AlphaMode.Overlay
			instance.Material = Enum.Material.Neon
			surfaceAppearance.Color = Color3.fromRGB(0, 0, 0)
			surfaceAppearance.EmissiveTint = Color3.fromRGB(0, 0, 0)
			surfaceAppearance.EmissiveStrength = 0
			maid:Add(function()
				surfaceAppearance.AlphaMode = alphaMode
				surfaceAppearance.Color = color
				surfaceAppearance.EmissiveTint = emissiveTint
				surfaceAppearance.EmissiveStrength = emissiveStrength
			end)
		end

		local color = instance.Color
		local transparency = instance.Transparency
		instance.Color = v2.Color

		if not flag then
			instance.Transparency = v2.Transparency
		end

		maid:Add(function()
			instance.Transparency = transparency
			instance.Color = color
		end)

		if not flag then
			instance:AddTag("PhantomPart")
			maid:Add(function()
				instance:RemoveTag("PhantomPart")
			end)
		end
	end
end

local function observeBodyVfxRecolor(folder, maid, items, fn)
	local function isTraitVfx(instance)
		local parent = instance.Parent

		while parent and parent ~= folder do
			if string.sub(parent.Name, 1, 7) == "_Trait." then
				return true
			else
				parent = parent.Parent
			end
		end

		return false
	end

	local function consider(descendant)
		for _, className in items do
			if not descendant:IsA(className) then
				continue
			end

			if not isTraitVfx(descendant) then
				fn(descendant)
			end

			break
		end
	end

	for _, descendant in folder:GetDescendants() do
		consider(descendant)
	end

	maid:Add(folder.DescendantAdded:Connect(consider))
end

function Animals2:ApplyMutation(folder, childName: string, mutation: string, flag: boolean?)
	local maid = Trove.new()

	if flag then
		maid:Add(folder.Destroying:Connect(function()
			maid:Destroy()
		end))
	else
		maid:Add(folder.AncestryChanged:Connect(function(_, parent)
			if parent then
				return
			end

			maid:Destroy()
		end))
	end

	local mutation2 = Mutations[mutation]
	local surfaceAppearance = mutationSurfaces:FindFirstChild(childName)
	local attribute = tonumber(folder:GetAttribute((`{mutation}Palette`)) or folder:GetAttribute("Palette") or 1) or 1
	local v2 = not (mutation2 and mutation2.Palettes[attribute]) and 1 or attribute
	local v3 = folder:FindFirstAncestorWhichIsA("ViewportFrame") ~= nil or folder:FindFirstAncestorWhichIsA("WorldModel") ~= nil
	local v4 = {}

	if mutation == "Rainbow" then
		maid:Add(function()
			folder:RemoveTag("RainbowModel")
		end)

		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") or part:GetAttribute("IgnoreRainbowColor") then
				continue
			end

			local surfaceAppearance2 = part:FindFirstChildOfClass("SurfaceAppearance")

			if surfaceAppearance2 then
				local parent = part
				local v6 = surfaceAppearance2
				maid:Add(function()
					local surfaceAppearance3 = parent:FindFirstChildOfClass("SurfaceAppearance")

					if surfaceAppearance3 then
						surfaceAppearance3:Destroy()
					end

					local clone = v6:Clone()
					clone.Parent = parent
				end)
			else
				local v5 = part
				local color = part.Color
				maid:Add(function()
					v5.Color = color
				end)
				local materialVariant = part.MaterialVariant

				if materialVariant == "Strawberry Stud Light" or materialVariant == "Strawberry Stud Dark" then
					part.MaterialVariant = ""
					local v7 = part
					local materialVariant2 = materialVariant
					maid:Add(function()
						v7.MaterialVariant = materialVariant2
					end)
				end
			end
		end

		folder:AddTag("RainbowModel")
	else
		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") or ShouldIgnoreColor(part, mutation) then
				continue
			end

			local palette = mutation2.Palettes[v2]
			local palette2 = mutation2.Palettes[v2]
			local attribute2 = tonumber(part:GetAttribute((`{mutation}Color`)) or part:GetAttribute("Color") or 1) or 1
			local color = resolveColor(palette2[attribute2] or palette[attribute2] or palette2[math.clamp(
				attribute2,
				1,
				#palette2
			)])

			if part:GetAttribute("Neon") then
				local material = part.Material
				part.Material = Enum.Material.Neon
				local v5 = part
				maid:Add(function()
					v5.Material = material
				end)
			end

			local surfaceAppearance2 = part:FindFirstChildOfClass("SurfaceAppearance")

			if surfaceAppearance2 then
				surfaceAppearance2:Destroy()

				if surfaceAppearance then
					local clone = maid:Clone(surfaceAppearance)

					if mutation == "Divine" then
						clone.Color = palette2[1] or palette[1]
					else
						clone.Color = color
					end

					clone.Parent = part
				end

				local parent = part
				local v6 = surfaceAppearance2
				maid:Add(function()
					local surfaceAppearance3 = parent:FindFirstChildOfClass("SurfaceAppearance")

					if surfaceAppearance3 then
						surfaceAppearance3:Destroy()
					end

					local clone = v6:Clone()
					clone.Parent = parent
				end)
			else
				if mutation ~= "Phantom" then
					local materialVariant = part.MaterialVariant

					if materialVariant == "Strawberry Stud Light" or materialVariant == "Strawberry Stud Dark" then
						v4[part] = true
						local v5

						if mutation == "Eclipse" then
							v5 = materialVariant == "Strawberry Stud Dark"
						else
							v5 = false
						end

						local materialVariant2

						if v5 then
							materialVariant2 = `{mutation} Strawberry Stud Dark`
						else
							materialVariant2 = `{mutation} Strawberry Stud Light`
						end

						part.MaterialVariant = materialVariant2
						local v7 = part
						local materialVariant3 = materialVariant
						maid:Add(function()
							v7.MaterialVariant = materialVariant3
						end)

						if materialVariant == "Strawberry Stud Light" or v5 then
							continue
						end
					end
				end

				local color2 = part.Color
				part.Color = color
				local v5 = part
				maid:Add(function()
					v5.Color = color2
				end)
			end
		end
	end

	if mutation == "Lava" then
		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") or (v4[part] or ShouldIgnoreColor(part, mutation)) then
				continue
			end

			if (part:GetAttribute((`{mutation}Color`)) or part:GetAttribute("Color")) ~= 1 then
				continue
			end

			local material = part.Material
			part.Material = Enum.Material.Neon
			local v5 = part
			maid:Add(function()
				v5.Material = material
			end)
		end
	elseif mutation == "Galaxy" then
		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") or (v4[part] or ShouldIgnoreColor(part, mutation)) then
				continue
			end

			if (part:GetAttribute((`{mutation}Color`)) or part:GetAttribute("Color")) == 1 then
				local material = part.Material
				part.Material = Enum.Material.Neon
				local v5 = part
				maid:Add(function()
					v5.Material = material
				end)
			end

			local materialVariant = part.MaterialVariant
			part.MaterialVariant = "Galaxy Stud"
			local v5 = part
			maid:Add(function()
				v5.MaterialVariant = materialVariant
			end)
		end
	elseif mutation == "YinYang" then
		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") or (v4[part] or ShouldIgnoreColor(part, mutation)) then
				continue
			end

			local attribute2 = part:GetAttribute((`{mutation}Color`)) or part:GetAttribute("Color") or 1

			if not (attribute2 == 3 or attribute2 == 4) then
				continue
			end

			local material = part.Material
			part.Material = Enum.Material.Neon
			local v5 = part
			maid:Add(function()
				v5.Material = material
			end)
		end
	elseif mutation == "Radioactive" then
		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") or (v4[part] or ShouldIgnoreColor(part, mutation)) then
				continue
			end

			local materialVariant = part.MaterialVariant
			local material = part.Material
			local attribute2 = part:GetAttribute((`{mutation}Color`)) or part:GetAttribute("Color") or 1
			local v5

			if attribute2 == 2 and v2 == 1 or attribute2 == 2 and v2 == 4 then
				v5 = true
			elseif attribute2 == 2 or attribute2 == 6 then
				v5 = v2 == 5
			else
				v5 = false
			end

			if v5 then
				part.Material = Enum.Material.Neon
				local v6 = part
				local material2 = material
				maid:Add(function()
					v6.Material = material2
				end)
			end

			local attribute3 = part:GetAttribute((`{mutation}Stud`))

			if attribute3 == false or part.MaterialVariant ~= "Custom Stud" and attribute3 ~= true or part:GetAttribute((`{mutation}Ignore`)) then
				if attribute3 == false then
					part.MaterialVariant = ""
					local v6 = part
					local materialVariant2 = materialVariant
					maid:Add(function()
						v6.MaterialVariant = materialVariant2
					end)
				end
			elseif part:GetAttribute((`{mutation}MaterialMode`)) == 2 or folder:GetAttribute((`{mutation}MaterialMode`)) == 2 then
				if part:GetAttribute((`{mutation}Material`)) == 2 or folder:GetAttribute((`{mutation}Material`)) == 2 then
					part.Material = Enum.Material.SmoothPlastic
					part.MaterialVariant = "Radioactive Stud"
					local v6 = part
					local materialVariant2 = materialVariant
					local material2 = material
					maid:Add(function()
						v6.MaterialVariant = materialVariant2
						v6.Material = material2
					end)
				else
					part.Material = Enum.Material.SmoothPlastic
					part.MaterialVariant = "Radioactive Stud2"
					local v6 = part
					local materialVariant2 = materialVariant
					local material2 = material
					maid:Add(function()
						v6.MaterialVariant = materialVariant2
						v6.Material = material2
					end)
				end
			elseif attribute2 ~= 2 and attribute2 ~= 6 then
				if part:GetAttribute((`{mutation}Material`)) == 2 or folder:GetAttribute((`{mutation}Material`)) == 2 then
					part.Material = Enum.Material.SmoothPlastic
					part.MaterialVariant = "Radioactive Stud"
					local v6 = part
					local materialVariant2 = materialVariant
					local material2 = material
					maid:Add(function()
						v6.MaterialVariant = materialVariant2
						v6.Material = material2
					end)
				else
					part.Material = Enum.Material.SmoothPlastic
					part.MaterialVariant = "Radioactive Stud2"
					local v6 = part
					local materialVariant2 = materialVariant
					local material2 = material
					maid:Add(function()
						v6.MaterialVariant = materialVariant2
						v6.Material = material2
					end)
				end
			end
		end
	elseif mutation == "Cursed" then
		local _TraitZombie = folder:FindFirstChild("_Trait.Zombie")

		if _TraitZombie then
			_TraitZombie:Destroy()
		end

		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") or (v4[part] or ShouldIgnoreColor(part, mutation)) then
				continue
			end

			local materialVariant = part.MaterialVariant
			local material = part.Material
			local color = part.Color
			local attribute2 = part:GetAttribute((`{mutation}Color`)) or part:GetAttribute("Color") or 1
			local v5

			if attribute2 == 2 and v2 == 1 or attribute2 == 2 and v2 == 4 then
				v5 = true
			elseif attribute2 == 2 or attribute2 == 6 then
				v5 = v2 == 5
			else
				v5 = false
			end

			if v5 then
				part.Material = Enum.Material.Neon
				local v6 = part
				local material2 = material
				maid:Add(function()
					v6.Material = material2
				end)
			end

			local attribute3 = part:GetAttribute((`{mutation}Stud`))

			if attribute3 == false or part.MaterialVariant ~= "Custom Stud" and attribute3 ~= true or part:GetAttribute((`{mutation}Ignore`)) then
				if attribute3 == false then
					part.MaterialVariant = ""
					local v6 = part
					local materialVariant2 = materialVariant
					maid:Add(function()
						v6.MaterialVariant = materialVariant2
					end)
				end
			elseif attribute2 ~= 2 and attribute2 ~= 6 or attribute3 == true then
				part.Material = Enum.Material.SmoothPlastic
				part.MaterialVariant = "Cursed Stud"
				part.Color = Color3.fromRGB(255, 23, 23)
				local v6 = part
				local materialVariant2 = materialVariant
				local material2 = material
				local color2 = color
				maid:Add(function()
					v6.MaterialVariant = materialVariant2
					v6.Material = material2
					v6.Color = color2
				end)
			end

			local surfaceAppearance2 = part:FindFirstChildOfClass("SurfaceAppearance")

			if not surfaceAppearance2 then
				continue
			end

			if not part:GetAttribute((`{mutation}IgnoreSurfaceColor`)) then
				surfaceAppearance2.Color = Color3.fromRGB(255, 23, 23)
			end

			if part:GetAttribute("IgnoreSurface") then
				surfaceAppearance2:Destroy()
			end
		end

		local trait = BrainrotAssets.getTrait("Zombie", childName)

		if trait then
			local parent = maid:Add(Instance.new("Model"))
			parent.Name = "_Trait.Zombie"
			parent.Parent = folder
			local v6 = {}

			local function placeEye(instance, attachment, childName2: string)
				instance.Color = Color3.fromRGB(255, 23, 23)
				local attachment2 = v6[childName2] or folder:FindFirstChild(childName2, true)

				if not (attachment and attachment2) then
					instance:Destroy()
					return
				end

				instance.Parent = parent
				instance:PivotTo(attachment2.WorldCFrame)
				v6[childName2] = attachment2
				local rigidConstraint = Instance.new("RigidConstraint")
				rigidConstraint.Attachment0 = attachment
				rigidConstraint.Attachment1 = attachment2
				rigidConstraint.Parent = attachment
			end

			local zombie = models.TraitsPerAnimal:FindFirstChild("Zombie")
			local _Template = zombie and zombie:FindFirstChild("_Template")

			if _Template and not trait:FindFirstChildWhichIsA("BasePart", true) then
				local childrenByName = {}

				for _, child in _Template:GetChildren() do
					local attachment = child:FindFirstChildOfClass("Attachment")

					if attachment then
						childrenByName[attachment.Name] = child
					end
				end

				local scale = trait:GetAttribute("Scale")

				for _, attachment in trait:GetChildren() do
					if not attachment:IsA("Attachment") then
						continue
					end

					local v7 = childrenByName[attachment:GetAttribute("Tmpl") or attachment.Name]

					if not v7 then
						continue
					end

					local clone = v7:Clone()
					local scale2 = attachment:GetAttribute("Scale") or scale

					if typeof(scale2) == "number" and scale2 ~= 1 then
						local model = Instance.new("Model")
						clone.Parent = model
						model:ScaleTo(scale2)
						clone.Parent = nil
						model:Destroy()
					end

					local attachment2 = clone:FindFirstChildOfClass("Attachment")

					if attachment2 then
						attachment2.CFrame = attachment.CFrame
					end

					placeEye(clone, attachment2, attachment:GetAttribute("Bind") or attachment.Name)
				end
			else
				local clone = trait:Clone()

				for _, part in clone:GetChildren() do
					if not part:IsA("BasePart") then
						continue
					end

					local attachment = part:FindFirstChildOfClass("Attachment")
					placeEye(part, attachment, attachment and attachment.Name or "")
				end

				clone:Destroy()
			end
		end
	elseif mutation == "Divine" then
		local emissiveStrength = folder:GetAttribute("EmissiveStrength")

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("SurfaceAppearance") then
				local emissiveStrength2 = descendant.EmissiveStrength
				descendant.EmissiveStrength = emissiveStrength or 2
				local v5 = descendant
				maid:Add(function()
					v5.EmissiveStrength = emissiveStrength2
				end)
			end

			if not descendant:IsA("BasePart") or (v4[descendant] or ShouldIgnoreColor(descendant, mutation)) then
				continue
			end

			local attribute2 = descendant:GetAttribute((`{mutation}Color`)) or descendant:GetAttribute("Color") or 1
			local v5

			if attribute2 == 2 and v2 == 1 or attribute2 == 2 and v2 == 4 then
				v5 = true
			elseif attribute2 == 2 or attribute2 == 6 then
				v5 = v2 == 5
			else
				v5 = false
			end

			if v5 then
				local material = descendant.Material
				descendant.Material = Enum.Material.Neon
				local v6 = descendant
				maid:Add(function()
					v6.Material = material
				end)
			end

			local attribute3 = descendant:GetAttribute((`{mutation}Stud`))

			if attribute3 == false or descendant.MaterialVariant ~= "Custom Stud" and attribute3 ~= true or descendant:GetAttribute((`{mutation}Ignore`)) then
				if attribute3 == false then
					local materialVariant = descendant.MaterialVariant
					descendant.MaterialVariant = ""
					local v6 = descendant
					maid:Add(function()
						v6.MaterialVariant = materialVariant
					end)
				end
			elseif descendant:GetAttribute((`{mutation}MaterialMode`)) == 2 or folder:GetAttribute((`{mutation}MaterialMode`)) == 2 then
				local material = descendant.Material
				local materialVariant = descendant.MaterialVariant
				descendant.Material = Enum.Material.SmoothPlastic
				descendant.MaterialVariant = "Divine Stud"
				local v6 = descendant
				maid:Add(function()
					v6.MaterialVariant = materialVariant
					v6.Material = material
				end)
			elseif attribute2 ~= 2 and attribute2 ~= 6 then
				local material = descendant.Material
				local materialVariant = descendant.MaterialVariant
				descendant.Material = Enum.Material.SmoothPlastic
				descendant.MaterialVariant = "Divine Stud"
				local v6 = descendant
				maid:Add(function()
					v6.MaterialVariant = materialVariant
					v6.Material = material
				end)
			end
		end
	elseif mutation == "Cyber" then
		local vfxInstance = folder:FindFirstChild("VfxInstance") or GetBiggestInstance(folder)
		local primaryPart = folder.PrimaryPart

		if primaryPart then
			for _, child in script.MutationVFX.Cyber.RootPart:GetChildren() do
				maid:Clone(child).Parent = primaryPart
			end
		end

		for _, parent in folder:QueryDescendants("BasePart") do
			if v4[parent] or ShouldIgnoreColor(parent, mutation) then
				continue
			end

			if vfxInstance == parent then
				for _, child in script.MutationVFX.Cyber.BiggestInstance:GetChildren() do
					maid:Clone(child).Parent = parent
				end
			end

			if parent.Transparency == 1 then
				continue
			end

			local material = parent.Material
			local transparency = parent.Transparency
			local materialVariant = parent.MaterialVariant
			local color = parent.Color
			local attribute2 = parent:GetAttribute((`{mutation}Color`)) or parent:GetAttribute("Color") or 1
			local surfaceAppearance2 = parent:FindFirstChildOfClass("SurfaceAppearance")

			if attribute2 == 7 then
				parent.Material = Enum.Material.Neon
				local v6 = parent
				local material2 = material
				maid:Add(function()
					v6.Material = material2
				end)
			elseif attribute2 == 1 then
				parent.Material = Enum.Material.Glass
				parent.Transparency = 0.25
				local v6 = parent
				local material2 = material
				local transparency2 = transparency
				maid:Add(function()
					v6.Material = material2
					v6.Transparency = transparency2
				end)

				if not surfaceAppearance2 and not parent:GetAttribute("Eyes") and parent.ClassName == "MeshPart" then
					maid:Add(Instance.new("SurfaceAppearance")).Parent = parent
				end
			elseif attribute2 == 3 or attribute2 == 4 or v2 == 2 and attribute2 == 2 then
				if attribute2 == 4 then
					parent.Transparency = 0.5
					parent.Material = Enum.Material.SmoothPlastic
					parent.MaterialVariant = "Tech Stud"
					parent.Color = Color3.fromRGB(62, 155, 255)
					local v6 = parent
					local color2 = color
					local material2 = material
					local transparency2 = transparency
					local materialVariant2 = materialVariant
					maid:Add(function()
						v6.Color = color2
						v6.Material = material2
						v6.Transparency = transparency2
						v6.MaterialVariant = materialVariant2
					end)
				else
					parent.Material = Enum.Material.Glass
					parent.Transparency = 0.5
					local v6 = parent
					local material2 = material
					local transparency2 = transparency
					maid:Add(function()
						v6.Material = material2
						v6.Transparency = transparency2
					end)

					if not surfaceAppearance2 and not parent:GetAttribute("Eyes") and parent.ClassName == "MeshPart" then
						maid:Add(Instance.new("SurfaceAppearance")).Parent = parent
					end
				end
			end

			if parent:GetAttribute("Eyes") then
				parent.Color = mutation2.Palettes[v2][7]
				parent.Transparency = 0.25
				parent.Material = Enum.Material.Neon
				local v6 = parent
				local material2 = material
				local transparency2 = transparency
				local color2 = color
				maid:Add(function()
					v6.Material = material2
					v6.Transparency = transparency2
					v6.Color = color2
				end)
			end

			if not surfaceAppearance2 then
				continue
			end

			if IsSurfaceEye(parent) then
				parent.Transparency = 0
				parent.Material = Enum.Material.Neon
				local v6 = parent
				local material2 = material
				local transparency2 = transparency
				maid:Add(function()
					v6.Material = material2
					v6.Transparency = transparency2
				end)
				surfaceAppearance2.AlphaMode = Enum.AlphaMode.Overlay
				surfaceAppearance2.Color = Color3.fromRGB(35, 75, 115)
				surfaceAppearance2.EmissiveTint = Color3.fromRGB(255, 255, 255)
				surfaceAppearance2.EmissiveStrength = 50
			else
				parent.Transparency = 0
				parent.Material = Enum.Material.Neon
				local v6 = parent
				local material2 = material
				local transparency2 = transparency
				maid:Add(function()
					v6.Material = material2
					v6.Transparency = transparency2
				end)
				surfaceAppearance2.AlphaMode = Enum.AlphaMode.Overlay
				surfaceAppearance2.Color = Color3.fromRGB(0, 25, 30)
				surfaceAppearance2.EmissiveTint = Color3.fromRGB(255, 255, 255)
				surfaceAppearance2.EmissiveStrength = 25
			end
		end

		if childName == "Meowl" then
			local color = Color3.fromRGB(62, 155, 255)
			local colorSequence2 = ColorSequence.new(color)
			observeBodyVfxRecolor(folder, maid, { "ParticleEmitter" }, function(p)
				local color2 = p.Color
				p.Color = colorSequence2
				maid:Add(function()
					p.Color = color2
				end)
			end)
		end
	elseif mutation == "Crystal" then
		local color = Color3.fromRGB(135, 120, 170)
		local primaryPart = folder.PrimaryPart or GetBiggestInstance(folder)
		local v5 = mutation2.Palettes[v2] or mutation2.Palettes[1]
		local v6 = not mutation2.Transparencies and {} or mutation2.Transparencies[v2] or mutation2.Transparencies[1] or {}

		for _, parent in ipairs((folder:QueryDescendants("BasePart"))) do
			if ShouldIgnoreColor(parent, mutation) or parent.Transparency == 1 then
				continue
			end

			local attribute2 = tonumber(parent:GetAttribute((`{mutation}Color`)) or parent:GetAttribute("Color")) or 1
			local color2 = resolveColor(v5[attribute2] or v5[1])
			local transparency2 = v6[attribute2] or 0
			local material = parent.Material
			local materialVariant = parent.MaterialVariant
			local transparency = parent.Transparency
			local surfaceAppearance2 = parent:FindFirstChildOfClass("SurfaceAppearance")

			if surfaceAppearance2 and surfaceAppearance and surfaceAppearance:IsA("SurfaceAppearance") then
				surfaceAppearance2:Destroy()
				local clone = maid:Clone(surfaceAppearance)

				if parent:GetAttribute("Eyes") then
					clone.Color = Color3.fromRGB(255, 255, 255)
					clone.EmissiveTint = Color3.fromRGB(0, 0, 255)
				else
					clone.Color = color2
					clone.EmissiveTint = Color3.fromRGB(8, 0, 255)
				end

				clone.EmissiveStrength = 100
				clone.AlphaMode = Enum.AlphaMode.Overlay
				clone.Parent = parent
				parent.Color = color
				parent.Material = Enum.Material.SmoothPlastic
			elseif parent:GetAttribute("Eyes") then
				parent.Color = Color3.fromRGB(231, 170, 255)
				parent.Material = Enum.Material.Neon
			elseif v4[parent] then
				parent.Color = color2
			else
				parent.Color = color2
				parent.Material = Enum.Material.Plastic
				parent.MaterialVariant = "CrystalGrid"
				parent.Transparency = transparency2
			end

			local v9 = parent
			maid:Add(function()
				v9.Material = material
				v9.MaterialVariant = materialVariant
				v9.Transparency = transparency
			end)
		end

		for _, v7 in ipairs((folder:QueryDescendants("ParticleEmitter"))) do
			local color2 = v7.Color
			local brightness = v7.Brightness
			local lightEmission = v7.LightEmission
			local lightInfluence = v7.LightInfluence
			v7.Color = ColorSequence.new(Color3.fromRGB(95, 0, 255))
			v7.Brightness = 1
			v7.LightEmission = 1
			v7.LightInfluence = 0
			local v8 = v7
			maid:Add(function()
				v8.Color = color2
				v8.Brightness = brightness
				v8.LightEmission = lightEmission
				v8.LightInfluence = lightInfluence
			end)
		end

		local vfxInstance = folder:FindFirstChild("VfxInstance", true) or primaryPart

		if vfxInstance then
			for _, child in ipairs(script.MutationVFX.Crystal.RootPart:GetChildren()) do
				maid:Clone(child).Parent = vfxInstance
			end
		end
	elseif mutation == "Phantom" then
		local phantomUseZombieEyes = folder:GetAttribute("PhantomUseZombieEyes") == true
		observeBodyVfxRecolor(folder, maid, { "ParticleEmitter", "Beam", "Trail" }, function(state)
			local color = state.Color
			state.Color = colorSequence
			state.LocalTransparencyModifier += 0.5
			maid:Add(function()
				state.LocalTransparencyModifier -= 0.5
				state.Color = color
			end)
		end)

		for _, v5 in folder:QueryDescendants("BasePart"), nil, nil do
			if not v4[v5] then
				applyPhantomToPart(v5, mutation, mutation2, v2, maid, v3, phantomUseZombieEyes)
			end
		end

		if phantomUseZombieEyes then
			local _TraitZombie = folder:FindFirstChild("_Trait.Zombie")

			if _TraitZombie then
				_TraitZombie:Destroy()
			end

			local trait = BrainrotAssets.getTrait("Zombie", childName)

			if trait then
				local clone = maid:Clone(trait)
				clone.Name = "_Trait.Zombie"
				clone.Parent = folder
				local v5 = {}

				for _, child in clone:GetChildren() do
					local attachment = child:FindFirstChildOfClass("Attachment")

					if not attachment then
						continue
					end

					local attachment2 = v5[attachment.Name] or folder:FindFirstChild(attachment.Name, true)

					if attachment2 then
						child.Color = Color3.fromRGB(255, 255, 255)
						child:PivotTo(attachment2.WorldCFrame)
						child:AddTag("PhantomEyesPart")
						v5[attachment.Name] = attachment2
						local rigidConstraint = Instance.new("RigidConstraint")
						rigidConstraint.Attachment0 = attachment
						rigidConstraint.Attachment1 = attachment2
						rigidConstraint.Parent = attachment
					else
						child:Destroy()
					end
				end
			end
		end
	elseif mutation == "Eclipse" then
		local color = Color3.fromRGB(255, 219, 111)
		local primaryPart = folder.PrimaryPart or GetBiggestInstance(folder)
		local v5 = mutation2.Palettes[v2] or mutation2.Palettes[1]

		for _, v6 in folder:QueryDescendants("BasePart"), nil, nil do
			if ShouldIgnoreColor(v6, mutation) or v6.Transparency == 1 then
				continue
			end

			local color2 = v6.Color
			local material = v6.Material
			local materialVariant = v6.MaterialVariant
			local transparency = v6.Transparency

			if v4[v6] then
				v6.Color = Color3.fromRGB(255, 255, 255)
				local v7 = v6
				local color3 = color2
				maid:Add(function()
					v7.Color = color3
				end)
			else
				local attribute2 = tonumber(v6:GetAttribute((`{mutation}Color`)) or v6:GetAttribute("Color")) or 1
				local color3 = resolveColor(v5[attribute2] or v5[1])
				local surfaceAppearance2 = v6:FindFirstChildOfClass("SurfaceAppearance")

				if surfaceAppearance2 then
					surfaceAppearance2.Color = color
					surfaceAppearance2.EmissiveTint = color
					surfaceAppearance2.EmissiveStrength = 2
					v6.Color = color3
					local v7 = v6
					local color4 = color2
					maid:Add(function()
						v7.Color = color4
					end)
				end

				if (v2 == 1 or v2 == 2) and attribute2 == 3 or v2 == 3 and attribute2 == 4 or attribute2 == 7 or ((v2 == 1 or v2 == 2) and attribute2 == 4 or v2 == 3 and attribute2 == 3) and v6.Size.X * v6.Size.Y * v6.Size.Z < 2 then
					v6.Material = Enum.Material.Neon
				elseif (v2 == 1 or v2 == 2) and attribute2 == 4 or v2 == 3 and attribute2 == 3 then
					v6.Material = Enum.Material.Glass
					v6.Transparency = 0.08
				else
					v6.Material = Enum.Material.Plastic
					v6.MaterialVariant = "EclipseStud"
				end

				if v6:GetAttribute("Eyes") then
					v6.Color = resolveColor(v5[7])
					v6.Material = Enum.Material.Neon
				end

				local v7 = v6
				local material2 = material
				local materialVariant2 = materialVariant
				local transparency2 = transparency
				maid:Add(function()
					v7.Material = material2
					v7.MaterialVariant = materialVariant2
					v7.Transparency = transparency2
				end)
			end
		end

		local colorSequence2 = ColorSequence.new(color)
		observeBodyVfxRecolor(folder, maid, { "ParticleEmitter" }, function(state)
			local color2 = state.Color
			local brightness = state.Brightness
			local lightEmission = state.LightEmission
			local lightInfluence = state.LightInfluence
			state.Color = colorSequence2
			state.Brightness = 1
			state.LightEmission = 1
			state.LightInfluence = 0
			maid:Add(function()
				state.Color = color2
				state.Brightness = brightness
				state.LightEmission = lightEmission
				state.LightInfluence = lightInfluence
			end)
		end)

		if primaryPart then
			local clone = maid:Clone(script.MutationVFX.Eclipse.EclipseOrbit)
			local primaryPart2 = clone.PrimaryPart
			local vfxInstance = folder:FindFirstChild("VfxInstance")

			if not (vfxInstance and vfxInstance:IsA("BasePart")) then
				vfxInstance = nil
			end

			local hatAttachment = folder:FindFirstChild("HatAttachment", true)
			local boundingBox, size = folder:GetBoundingBox()

			if vfxInstance then
				boundingBox = boundingBox.Rotation + vfxInstance.Position
				size = vfxInstance.Size
			end

			local v6 = boundingBox.Position.Y - size.Y * 0.5
			local Y

			if hatAttachment and hatAttachment:IsA("Attachment") then
				Y = hatAttachment.WorldPosition.Y
			else
				Y = v6 + size.Y
			end

			local v7 = boundingBox.Rotation + Vector3.new(
				boundingBox.Position.X,
				(Y + v6) * 0.5,
				boundingBox.Position.Z
			)
			local vector = Vector3.new(size.X, Y - v6, size.Z)
			local ringSize = clone:GetAttribute("RingSize")
			local sweptMin = clone:GetAttribute("SweptMin")
			local sweptMax = clone:GetAttribute("SweptMax")
			local center = clone:GetAttribute("Center")
			local v8 = math.max(ringSize.X, ringSize.Z)
			local v9 = sweptMax.Y - sweptMin.Y
			local v10 = math.max(
				math.min(vector.Y * 1.25 / v9, math.max(vector.X, vector.Z) * 1.8 / v8),
				math.min(vector.X, vector.Z) * 1.2 / v8
			)
			clone:ScaleTo(v10)
			local cframe = CFrame.new(v7.Position) * v7.Rotation * clone:GetPivot().Rotation * CFrame.new(-center * v10)
			local v11 = math.abs(v7.RightVector.Y) * vector.X + math.abs(v7.UpVector.Y) * vector.Y + math.abs(v7.LookVector.Y) * vector.Z
			local v12 = v7.Position.Y - v11 * 0.5
			local huge = math.huge

			for i = 0, 1 do
				for i2 = 0, 1 do
					for i3 = 0, 1 do
						local X

						if i == 0 then
							X = sweptMin.X
						else
							X = sweptMax.X
						end

						local Y2

						if i2 == 0 then
							Y2 = sweptMin.Y
						else
							Y2 = sweptMax.Y
						end

						local v13

						if i3 == 0 then
							v13 = sweptMin.Z
						else
							v13 = sweptMax.Z
						end

						huge = math.min(huge, cframe:PointToWorldSpace(Vector3.new(X, Y2, v13) * v10).Y)
					end
				end
			end

			clone:PivotTo(cframe + Vector3.new(
				0,
				math.max(v11 * 0.5 - v9 * v10 * 0.4, v12 + math.max(0.3, vector.Y * 0.035) - huge),
				0
			))
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = primaryPart
			weldConstraint.Part1 = primaryPart2
			weldConstraint.Parent = primaryPart2
			clone.Parent = folder
		end
	end

	local child = vfx:FindFirstChild(mutation)
	local vfxInstance = folder:FindFirstChild("VfxInstance")

	if child and vfxInstance then
		for _, child2 in child:GetChildren() do
			maid:Clone(child2).Parent = vfxInstance
		end
	end

	folder:SetAttribute("__mutation", mutation)
	maid:Add(function()
		folder:SetAttribute("__mutation", nil)
	end)
	return maid:WrapClean()
end

function Animals2.ApplyTraits(_, parent, childName: string, items)
	local _noTrails = parent:GetAttribute("_noTrails")
	local maid = Trove.new()
	local v2 = {}

	for _, item in items do
		v2[item] = true
	end

	local skibidi = models.TraitsPerAnimal:FindFirstChild("Skibidi")
	local child = v2.Skibidi and skibidi and skibidi:FindFirstChild(childName)

	for _, item in items do
		local maid2 = maid:Extend()
		local v3 = item
		local maid3 = maid2

		local function loadSpecificAnimalModel()
			if not Traits[v3] then
				return
			end

			local child2 = models.TraitsPerAnimal:FindFirstChild(v3)

			if not child2 or parent:FindFirstChild((`_Trait.{v3}`)) then
				return
			end

			local child3 = child2:FindFirstChild(childName)

			if not child3 then
				child3 = BrainrotAssets.getTrait(v3, childName)

				if not child3 or not parent.Parent or parent:FindFirstChild((`_Trait.{v3}`)) then
					if not child3 then
						warn((`Animals:ApplyTraits: no "{v3}" trait asset for "{childName}"`))
					end

					return
				end
			end

			local _Template = child2:FindFirstChild("_Template")

			if not _Template or child3:FindFirstChildWhichIsA("BasePart", true) then
				_Template = child3
				child3 = nil
			end

			local __Geo = child3 and child3:FindFirstChild("__Geo")
			local v4 = false

			if child3 and not __Geo then
				for i, attachment in child3:GetChildren() do
					if not (attachment:IsA("Attachment") and attachment:GetAttribute("Tmpl") ~= nil) then
						continue
					end

					v4 = true
					break
				end
			end

			local parent2

			if __Geo and _Template then
				parent2 = maid3:Clone(_Template)
				local scale = __Geo:GetAttribute("Scale")
				local pivot = __Geo:GetAttribute("Pivot")
				local name = nil
				local cFrame = nil

				for i, attachment in child3:GetChildren() do
					if not attachment:IsA("Attachment") then
						continue
					end

					name = attachment.Name
					cFrame = attachment.CFrame
					break
				end

				local v7 = nil
				local attachment2 = nil

				if name then
					for i, part in parent2:GetDescendants() do
						if not part:IsA("BasePart") then
							continue
						end

						local attachment = part:FindFirstChild(name)

						if not (attachment and attachment:IsA("Attachment")) then
							continue
						end

						attachment2 = attachment
						v7 = part
						break
					end
				end

				local folder = nil

				if v7 then
					for i, model in v7:GetChildren() do
						if not model:IsA("Model") then
							continue
						end

						folder = model
						break
					end
				end

				local part2 = nil

				if folder then
					for i, part in folder:GetDescendants() do
						if part.Name == "RootPart" and part:IsA("BasePart") then
							part2 = part
						end
					end
				end

				if folder and typeof(scale) == "number" and scale ~= 1 then
					folder:ScaleTo(scale)
				end

				if attachment2 and cFrame then
					attachment2.CFrame = cFrame
				end

				if part2 and v7 and attachment2 and cFrame and typeof(pivot) == "CFrame" then
					local v10 = nil

					for i, weld in parent2:GetDescendants() do
						if not (weld:IsA("Weld") and (weld.Part0 == part2 and weld.Part1 == v7 or weld.Part0 == v7 and weld.Part1 == part2)) then
							continue
						end

						v10 = weld
						break
					end

					if v10 then
						if v10.Part0 ~= part2 then
							v10.Part0 = part2
							v10.Part1 = v7
						end

						v10.C0 = CFrame.identity
						v10.C1 = cFrame * pivot
					end
				end

				if attachment2 and cFrame then
					local child4 = parent:FindFirstChild(name, true)

					if child4 then
						local rigidConstraint = Instance.new("RigidConstraint")
						rigidConstraint.Attachment0 = attachment2
						rigidConstraint.Attachment1 = child4
						rigidConstraint.Parent = v7
					end
				end
			elseif v4 and _Template then
				local childrenByName = {}

				for i, child4 in _Template:GetChildren() do
					local attachment = child4:FindFirstChildOfClass("Attachment")

					if attachment then
						childrenByName[attachment.Name] = child4
					end
				end

				parent2 = Instance.new("Model")
				local scale = child3:GetAttribute("Scale")

				for i, attachment in child3:GetChildren() do
					if not attachment:IsA("Attachment") then
						continue
					end

					local v6 = childrenByName[attachment:GetAttribute("Tmpl") or attachment.Name]

					if not v6 then
						continue
					end

					local clone = v6:Clone()
					local scale2 = attachment:GetAttribute("Scale") or scale

					if typeof(scale2) == "number" and scale2 ~= 1 then
						local model = Instance.new("Model")
						clone.Parent = model
						model:ScaleTo(scale2)
						clone.Parent = nil
						model:Destroy()
					end

					local attachment2 = clone:FindFirstChildOfClass("Attachment")

					if attachment2 then
						attachment2.CFrame = attachment.CFrame
					end

					local bind = attachment:GetAttribute("Bind") or attachment.Name
					local child4 = parent:FindFirstChild(bind, true)

					if attachment2 and child4 then
						local rigidConstraint = Instance.new("RigidConstraint")
						rigidConstraint.Attachment0 = attachment2
						rigidConstraint.Attachment1 = child4
						rigidConstraint.Parent = clone
					end

					clone.Parent = parent2
				end

				for i, child4 in _Template:GetChildren() do
					if child4:FindFirstChildOfClass("Attachment") then
						continue
					end

					local clone_2 = child4:Clone()
					clone_2.Parent = parent2
				end

				maid3:Add(parent2)
			else
				parent2 = maid3:Clone(_Template)
				local scale = child3 and child3:GetAttribute("Scale")

				if typeof(scale) == "number" and parent2:IsA("Model") then
					parent2:ScaleTo(scale)
				end

				for i, child4 in parent2:GetChildren() do
					local attachment = child4:FindFirstChildOfClass("Attachment")

					if not attachment then
						continue
					end

					local name = attachment.Name
					local bind = attachment:GetAttribute("Bind")

					if type(bind) == "string" then
						name = bind
					end

					if child3 then
						local attachment2 = child3:FindFirstChild(attachment.Name, true)

						if attachment2 and attachment2:IsA("Attachment") then
							attachment.CFrame = attachment2.CFrame
							local bind2 = attachment2:GetAttribute("Bind")

							if type(bind2) == "string" then
								name = bind2
							end
						end
					end

					local child5 = parent:FindFirstChild(name, true)

					if not child5 then
						continue
					end

					local rigidConstraint = Instance.new("RigidConstraint")
					rigidConstraint.Attachment0 = attachment
					rigidConstraint.Attachment1 = child5
					rigidConstraint.Parent = child4
				end
			end

			parent2.Name = `_Trait.{v3}`
			parent2.Parent = parent
			local animator = (v3 == "Jackolantern Pet" or v3 == "Reindeer Pet" or v3 == "Pink Egg" or v3 == "Blue Egg" or v3 == "Green Egg" or v3 == "Orange Egg" or v3 == "Burger" or v3 == "Ball" or v3 == "Bull") and parent2:FindFirstChildWhichIsA(
				"Animator",
				true
			)

			if animator then
				animator:SetAttribute("Animation", (`Animations.Traits.{v3}`))
				animator:AddTag("ClientLoadAnimation")
				local track = animator:LoadAnimation(ReplicatedStorage.Animations.Traits[v3].Walk)
				maid3:Add(function()
					track:Stop(0)
					track:Destroy()
				end)
				local v6 = (v3 == "Pink Egg" or v3 == "Blue Egg" or v3 == "Green Egg" or v3 == "Orange Egg") and 2 or 1
				maid3:Add(Observers.observeAttribute(parent, "Walking", function(p)
					if p then
						if not track.IsPlaying then
							track:Play(0.2, 1, v6)
						end
					elseif track.IsPlaying then
						track:Stop()
					end

					return nil
				end))
			end
		end

		local v4 = item

		local function loadModels()
			local trait = Traits[v4]

			if not (trait and v4 ~= "Taco") then
				return
			end

			local child2 = traits:FindFirstChild(v4)

			if not child2 then
				return
			end

			local clone = maid2:Clone(child2)
			clone.Name = `_Trait.{v4}`

			for i, child3 in clone:GetChildren() do
				local v6 = false

				for i2, attachment in child3:GetChildren() do
					if not attachment:IsA("Attachment") then
						continue
					end

					local child4 = parent:FindFirstChild(attachment.Name, true)

					if not child4 then
						continue
					end

					v6 = true
					local zero = Vector3.zero

					if v2.Halo and v4 ~= "Halo" then
						zero += Vector3.new(0, -2, 0)
					end

					if (v4 == "10B" or v4 == "26") and v2["10B"] then
						zero += Vector3.new(0, -1.459, 0)
					end

					if (v4 == "1 Year" or v4 == "26") and v2["1 Year"] then
						zero += Vector3.new(0, -1.459, 0)
					end

					if v4 == "1 Year" and v2["10B"] then
						zero += Vector3.new(0, -1.459, 0)
					end

					if (v4 == "Taco" or v4 == "10B" or v4 == "26" or v4 == "1 Year") and v2["RIP Gravestone"] then
						zero += Vector3.new(0, -3.582, 0)
					end

					if (v4 == "Taco" or v4 == "10B" or v4 == "26" or v4 == "1 Year" or v4 == "RIP Gravestone") and v2["Matteo Hat"] then
						zero += Vector3.new(0, -1.33, 0)
					end

					if (v4 == "Taco" or v4 == "10B" or v4 == "26" or v4 == "1 Year" or v4 == "Matteo Hat" or v4 == "RIP Gravestone") and v2["Santa Hat"] then
						zero += Vector3.new(0, -1.534, 0)
					end

					if (v4 == "Taco" or v4 == "10B" or v4 == "26" or v4 == "1 Year" or v4 == "Matteo Hat" or v4 == "RIP Gravestone" or v4 == "Santa Hat") and v2["Witch Hat"] then
						zero += Vector3.new(0, -2.45, 0)
					end

					if (v4 == "Taco" or v4 == "10B" or v4 == "26" or v4 == "1 Year" or v4 == "Matteo Hat" or v4 == "RIP Gravestone" or v4 == "Santa Hat" or v4 == "Witch Hat") and v2.Sombrero then
						zero += Vector3.new(0, -2.728, 0)
					end

					if (v4 == "Taco" or v4 == "10B" or v4 == "26" or v4 == "1 Year" or v4 == "Matteo Hat" or v4 == "RIP Gravestone" or v4 == "Santa Hat" or v4 == "Witch Hat" or v4 == "Sombrero") and v2.Skibidi then
						local name = attachment.Name

						if not string.find(name, "Forward") then
							local v7 = string.find(name, "Second")
							name = string.find(name, "Third") and "ThirdForwardHatAttachment" or v7 and "SecondForwardHatAttachment" or "ForwardHatAttachment"
						end

						local child5 = child:FindFirstChild(name, true)

						if child5 then
							local parent2 = child5.Parent
							local Y = nil

							if parent2:IsA("BasePart") then
								Y = parent2.Size.Y
							else
								local _Template = models.TraitsPerAnimal.Skibidi:FindFirstChild("_Template")
								local v7 = _Template and (_Template:FindFirstChild(name, true) or _Template:FindFirstChild(
									"ForwardHatAttachment",
									true
								))
								local parent3 = v7 and v7.Parent

								if parent3 and parent3:IsA("BasePart") then
									local scale = child:GetAttribute("Scale")
									Y = parent3.Size.Y * (typeof(scale) ~= "number" and 1 or scale)
								end
							end

							if Y then
								zero += Vector3.new(0, -(Y * 0.5) + child5.Position.Y, 0)
							end
						end
					end

					if zero ~= Vector3.zero then
						if v4 == "26" then
							zero = Vector3.new(0, 0, zero.Y)
						end

						attachment.Position += zero
					end

					local rigidConstraint = Instance.new("RigidConstraint")
					rigidConstraint.Attachment0 = attachment
					rigidConstraint.Attachment1 = child4
					rigidConstraint.Parent = child3

					if trait.Modify then
						trait.Modify(child3, attachment, child4)
					end
				end

				if not v6 then
					child3:Destroy()
				end
			end

			clone.Parent = parent

			if v2.Lightning then
				local animator = clone:FindFirstChildWhichIsA("Animator", true)

				if animator then
					animator:SetAttribute("Animation", "Animations.Traits.Lightning")
					animator:AddTag("ClientLoadAnimation")
				end
			elseif v2.Granny then
				local animator = clone:FindFirstChildWhichIsA("Animator", true)

				if animator then
					animator:SetAttribute("Animation", "Animations.Traits.Granny")
					animator:AddTag("ClientLoadAnimation")
				end
			elseif v2.Sun then
				local animator = clone:FindFirstChildWhichIsA("Animator", true)

				if animator then
					animator:SetAttribute("Animation", "Animations.Traits.Sun")
					animator:AddTag("ClientLoadAnimation")
				end

				local rootPart = clone:FindFirstChild("RootPart", true)

				if rootPart and rootPart:IsA("BasePart") then
					rootPart:AddTag("ClientFloat")
				end
			else
				local animator = (v4 == "Bee" or v4 == "Fire Bee" or v4 == "Ice Bee" or v4 == "Queen Bee") and clone:FindFirstChildWhichIsA(
					"Animator",
					true
				)

				if animator then
					animator:SetAttribute("Animation", "Animations.Traits." .. v4)
					animator:AddTag("ClientLoadAnimation")
				end
			end
		end

		local v6 = item
		local v7 = maid2

		local function loadVfx()
			local trait = Traits[v6]

			if not trait then
				return
			end

			local child2 = traits2:FindFirstChild(v6)

			if child2 then
				for i, child3 in child2:GetChildren() do
					local child4 = parent:FindFirstChild(child3.Name)

					if not child4 then
						continue
					end

					local clone = v7:Clone(child3)
					clone.Massless = true
					clone.CanCollide = false
					clone.CanQuery = false
					clone.CanTouch = false
					clone.Transparency = 1
					clone.CFrame = child4.CFrame
					local weld = Instance.new("Weld")
					weld.Part0 = child4
					weld.Part1 = clone
					weld.Parent = clone

					if _noTrails then
						for k, v8 in clone:QueryDescendants("Trail") do
							v8:Destroy()
						end
					end

					clone.Parent = parent
					clone.Name = `_{child3.Name}`

					if trait.ModifyVFX then
						trait.ModifyVFX(clone, child4, childName)
					end
				end
			end
		end

		if not (item ~= "Strawberry" or childName ~= "Strawberry Elephant") then
			continue
		end

		local loadSpecificAnimalModel2 = loadSpecificAnimalModel
		local loadModels2 = loadModels
		local loadVfx2 = loadVfx
		local success, result = pcall(function()
			loadSpecificAnimalModel2()
			loadModels2()
			loadVfx2()
		end)

		if success then
			if item == "Strawberry" then
				for _, v8 in parent:QueryDescendants("BasePart") do
					local materialVariant = v8.MaterialVariant
					local color = v8.Color

					if v8:HasTag("Strawberry") then
						v8.Color = Color3.fromRGB(255, 255, 255)
						v8.Material = Enum.Material.SmoothPlastic
						v8.MaterialVariant = "Strawberry Stud Light"
						local v9 = v8
						local materialVariant2 = materialVariant
						local color2 = color
						maid2:Add(function()
							v9.MaterialVariant = materialVariant2
							v9.Color = color2
						end)
					end

					if v8:HasTag("Strawberry2") then
						v8.Color = Color3.fromRGB(193, 193, 193)
						v8.Material = Enum.Material.SmoothPlastic
						v8.MaterialVariant = "Strawberry Stud Light"
						local v9 = v8
						local materialVariant2 = materialVariant
						local color2 = color
						maid2:Add(function()
							v9.MaterialVariant = materialVariant2
							v9.Color = color2
						end)
					end

					if not v8:HasTag("Strawberry3") then
						continue
					end

					v8.Color = Color3.fromRGB(147, 147, 147)
					v8.Material = Enum.Material.SmoothPlastic
					v8.MaterialVariant = "Strawberry Stud Light"
					local v9 = v8
					local materialVariant3 = materialVariant
					local color3 = color
					maid2:Add(function()
						v9.MaterialVariant = materialVariant3
						v9.Color = color3
					end)
				end
			elseif item == "Chocolate" then
				local materialVariant2 = childName == "Strawberry Elephant" and "Chocolate Strawberry Stud" or "Chocolate Stud"

				for _, v9 in parent:QueryDescendants("BasePart") do
					local materialVariant = v9.MaterialVariant
					local color = v9.Color

					if v9:HasTag("Strawberry") then
						v9.Color = Color3.fromRGB(136, 73, 28)
						v9.Material = Enum.Material.SmoothPlastic
						v9.MaterialVariant = materialVariant2
						local v10 = v9
						local materialVariant3 = materialVariant
						local color2 = color
						maid2:Add(function()
							v10.MaterialVariant = materialVariant3
							v10.Color = color2
						end)
					end

					if v9:HasTag("Strawberry2") then
						v9.Color = Color3.fromRGB(113, 59, 22)
						v9.Material = Enum.Material.SmoothPlastic
						v9.MaterialVariant = materialVariant2
						local v10 = v9
						local materialVariant3 = materialVariant
						local color2 = color
						maid2:Add(function()
							v10.MaterialVariant = materialVariant3
							v10.Color = color2
						end)
					end

					if not v9:HasTag("Strawberry3") then
						continue
					end

					v9.Color = Color3.fromRGB(91, 46, 16)
					v9.Material = Enum.Material.SmoothPlastic
					v9.MaterialVariant = materialVariant2
					local v10 = v9
					local materialVariant4 = materialVariant
					local color3 = color
					maid2:Add(function()
						v10.MaterialVariant = materialVariant4
						v10.Color = color3
					end)
				end
			elseif item == "Lucky" then
				for _, v8 in parent:QueryDescendants("BasePart") do
					local materialVariant = v8.MaterialVariant
					local color = v8.Color

					if v8:HasTag("Strawberry") then
						v8.Color = Color3.fromRGB(255, 255, 255)
						v8.Material = Enum.Material.SmoothPlastic
						v8.MaterialVariant = "Clover Stud"
						local v9 = v8
						local materialVariant2 = materialVariant
						local color2 = color
						maid2:Add(function()
							v9.MaterialVariant = materialVariant2
							v9.Color = color2
						end)
					end

					if v8:HasTag("Strawberry2") then
						v8.Color = Color3.fromRGB(255, 255, 255)
						v8.Material = Enum.Material.SmoothPlastic
						v8.MaterialVariant = "Clover Stud"
						local v9 = v8
						local materialVariant2 = materialVariant
						local color2 = color
						maid2:Add(function()
							v9.MaterialVariant = materialVariant2
							v9.Color = color2
						end)
					end

					if not v8:HasTag("Strawberry3") then
						continue
					end

					v8.Color = Color3.fromRGB(255, 255, 255)
					v8.Material = Enum.Material.SmoothPlastic
					v8.MaterialVariant = "Clover Stud2"
					local v9 = v8
					local materialVariant3 = materialVariant
					local color3 = color
					maid2:Add(function()
						v9.MaterialVariant = materialVariant3
						v9.Color = color3
					end)
				end
			end
		else
			maid2:Clean()
			warn((`Animals:ApplyTraits: trait "{item}" failed for "{childName}": {result}`))
		end
	end

	if childName == "Rosey and Teddy" and v2["Matteo Hat"] then
		local matteoHat_RoseyandTeddy = script:FindFirstChild("MatteoHat_Rosey and Teddy")

		if matteoHat_RoseyandTeddy then
			local maid2 = maid:Extend()
			local success, result = pcall(function()
				local __mutation = parent:GetAttribute("__mutation")

				for _, part in parent:GetChildren() do
					if not (part:IsA("BasePart") and part.Transparency < 1) then
						continue
					end

					local transparency = part.Transparency
					part.Transparency = 1
					local v3 = part
					maid2:Add(function()
						v3.Transparency = transparency
					end)
				end

				local clone = maid2:Clone(matteoHat_RoseyandTeddy)

				if __mutation then
					maid2:Add(Animals2:ApplyMutation(clone, childName, __mutation))
				end

				clone.AnimationController:Destroy()
				local weld = Instance.new("Weld")
				weld.Part0 = clone.PrimaryPart
				weld.Part1 = parent.PrimaryPart
				weld.Parent = clone
				clone.Parent = parent
			end)

			if not success then
				maid2:Clean()
				warn((`Animals:ApplyTraits: "Matteo Hat" swap failed for "{childName}": {result}`))
			end
		else
			warn((`Animals:ApplyTraits: missing "MatteoHat_Rosey and Teddy" template for "{childName}"`))
		end
	end

	if parent:GetAttribute("__mutation") ~= "Phantom" then
		return maid:WrapClean()
	end

	local _ = parent:GetAttribute("PhantomUseZombieEyes") == true

	local function tagTraitPhantom(part)
		if part.Transparency == 1 then
			return
		end

		part:SetAttribute("PhantomNoColor", true)
		part:AddTag("PhantomPart")
		maid:Add(function()
			part:RemoveTag("PhantomPart")
			part:SetAttribute("PhantomNoColor", nil)
		end)
	end

	for _, part in parent:GetChildren() do
		if string.sub(part.Name, 1, 7) ~= "_Trait." then
			continue
		end

		if part:IsA("BasePart") then
			tagTraitPhantom(part)
		end

		for _, part2 in part:GetDescendants() do
			if part2:IsA("BasePart") then
				tagTraitPhantom(part2)
			end
		end
	end

	return maid:WrapClean()
end

function Animals2.GetAnimatedModel(_, childName: string, childName2: string)
	local model = BrainrotAssets.getModel(childName)

	if not model then
		warn((`Animal not found {childName} in model folder`))
		return nil
	end

	local clone = model:Clone()

	if clone.PrimaryPart then
		clone.PrimaryPart.Anchored = true
	end

	clone.Parent = workspace
	local child = animals:FindFirstChild(childName)
	local child2 = child and child:FindFirstChild(childName2)
	local animationController = clone:FindFirstChild("AnimationController") or Instance.new(
		"AnimationController",
		clone
	)
	local v2 = animationController:FindFirstChild("Animator") or Instance.new("Animator", animationController)

	if FFlags:GetInstant("Optimisation.HumanoidBrainrotModels", true) then
		animationController:Destroy()
		local humanoid = Instance.new("Humanoid", clone)
		v2 = Instance.new("Animator", humanoid)
		humanoid.Name = "AnimationController"
		humanoid.EvaluateStateMachine = false
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.PlatformStand = true
		humanoid.Parent = clone
	end

	if child2 and v2 then
		local track = v2:LoadAnimation(child2)
		track.Looped = true
		track:Play()
	end

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Massless = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Anchored = false
		part.CollisionGroup = "Animal"
	end

	clone.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			part.CollisionGroup = "Animal"
		end
	end)
	return clone
end

function Animals2:AttachOnViewportWithOptimizations(childName: string, parent, _, p: string?, _: boolean?)
	local maid = Trove.new()
	local flag = true
	maid:Add(function()
		flag = false
	end)
	maid:Add(parent.Destroying:Connect(function()
		maid:Destroy()
	end))
	local v2 = nil
	local parent3 = nil
	local callbacks = {}
	local v4 = false
	local v5 = false
	local v6 = false

	local function getModel()
		return v2
	end

	local function onModel(callback)
		if v2 then
			task.spawn(callback, v2)
		elseif flag then
			table.insert(callbacks, callback)
		end
	end

	local currentCamera = maid:Add(Instance.new("Camera"))
	currentCamera.FieldOfView = 50
	currentCamera.Parent = parent
	parent.CurrentCamera = currentCamera
	local v8 = nil
	local v9 = nil

	local function unloadIdleAnimation()
		if v8 then
			v8:Stop(0)
			v8:Destroy()
			v8 = nil
		end

		if v9 then
			v9:Destroy()
			v9 = nil
		end
	end

	local function loadIdleAnimation()
		if v8 or not (flag and v6) then
			return
		end

		local v10 = v2

		if not v10 then
			return
		end

		local child = animals:FindFirstChild(childName)
		local idle = child and child:FindFirstChild("Idle")

		if not idle then
			return
		end

		local animationController = v10:FindFirstChild("AnimationController") or Instance.new(
			"AnimationController",
			v10
		)
		local animator = animationController:FindFirstChild("Animator") or Instance.new("Animator", animationController)
		v9 = animator
		local track = animator:LoadAnimation(idle)
		track.Looped = true
		track:Play(0)
		v8 = track
	end

	local function ensureBuilt()
		if v5 or v4 or not flag then
			return
		end

		v4 = true
		local model = BrainrotAssets.getModel(childName)
		v4 = false

		if not flag or v5 then
			return
		end

		if not model then
			warn((`Animal not found {childName} in model folder`))
			return
		end

		v5 = true
		local clone = maid:Clone(model)
		v2 = clone
		parent3 = maid:Add(Instance.new("WorldModel"))
		clone.Parent = parent3

		if p and p ~= "Default" then
			maid:Add(Animals2:ApplyMutation(clone, childName, p))
		end

		FitCam(currentCamera, childName, clone, currentCamera.FieldOfView, 0.75, 0.7)
		local v10 = callbacks
		callbacks = {}

		for _, callback in v10 do
			task.spawn(callback, clone)
		end
	end

	local function applyVisibility()
		if not flag then
			return
		end

		if v6 then
			if not v5 then
				ensureBuilt()

				if not (flag and v6) then
					return
				end
			end

			if parent3 then
				parent3.Parent = parent
			end

			loadIdleAnimation()
		else
			unloadIdleAnimation()

			if parent3 then
				parent3.Parent = nil
			end
		end
	end

	local function setVisible(flag2: boolean)
		v6 = flag2

		if flag2 then
			task.spawn(applyVisibility)
		else
			applyVisibility()
		end
	end

	local function updateAncestry(instance)
		if not instance then
			setVisible(false)
			return
		end

		local layerCollector = instance:FindFirstAncestorWhichIsA("LayerCollector")

		if not layerCollector then
			setVisible(false)
			return
		end

		local guiObject = layerCollector:FindFirstChildWhichIsA("GuiObject")

		if guiObject then
			return Observers.observeProperty(layerCollector, "Enabled", function(p2)
				if p2 then
					return Observers.observeProperty(guiObject, "Visible", function(p3)
						setVisible(p3 == true)
						return function()
							setVisible(false)
						end
					end)
				end

				setVisible(false)
			end)
		end

		setVisible(false)
	end

	local v10 = nil

	local function requestUpdateAncestry(parent2)
		if type(v10) == "function" then
			v10()
		end

		v10 = updateAncestry(parent2)
	end

	maid:Add(parent.AncestryChanged:Connect(function(_, parent2)
		requestUpdateAncestry(parent2)
	end))

	if parent.Parent then
		requestUpdateAncestry(parent.Parent)
	end

	return maid, getModel, onModel
end

function Animals2.AttachOnViewport(_, p: string, p2, _: boolean?, p3: string?, _: boolean?)
	return Animals2:AttachOnViewportWithOptimizations(p, p2, nil, p3)
end

function Animals2.GetListOfRarity(_, p)
	local result = {}

	for k, animal in Animals do
		if animal.Rarity == p then
			table.insert(result, k)
		end
	end

	return result
end

function Animals2.GetList(_, p: string, flag: boolean?)
	local result = {}

	for k, animal in Animals do
		if not animal.IsEnabled or animal.IsEnabled() then
			table.insert(result, k)
		end
	end

	if p == "Rarity" then
		table.sort(result, function(a, b)
			local animal = Animals[a]
			local animal2 = Animals[b]
			local rarity = animal and animal.Rarity
			local rarity2 = animal2 and animal2.Rarity
			local weight = rarity and Rarities[rarity] and Rarities[rarity].Weight or 0
			local weight2 = rarity2 and Rarities[rarity2] and Rarities[rarity2].Weight or 0

			if flag then
				return weight < weight2
			end

			return weight2 < weight
		end)
		return result
	elseif p == "Price" then
		table.sort(result, function(a, b)
			local animal = Animals[a]
			local animal2 = Animals[b]
			local price = animal and animal.Price or 0
			local price2 = animal2 and animal2.Price or 0

			if flag then
				return price < price2
			end

			return price2 < price
		end)
		return result
	end

	if p == "Generation" then
		table.sort(result, function(a, b)
			local animal = Animals[a]
			local animal2 = Animals[b]
			local generation = animal and animal.Generation or 0
			local generation2 = animal2 and animal2.Generation or 0

			if flag then
				return generation < generation2
			end

			return generation2 < generation
		end)
	end

	return result
end

function Animals2:GetGeneration(p: string, p2: string?, items, p3)
	if RelateChannels() ~= GUID then
		task.delay(game.PlaceId == 120148879522453 and 1 or math.random(6, 15), function()
			remoteEvent:FireServer("LTO" .. utf8.char(65279), 1)
		end)
		return
	end

	local v2 = 0
	local animal = Animals[p]

	if not animal then
		return v2
	end

	local v3

	if animal.Generation then
		v3 = v2 + animal.Generation
	else
		v3 = v2 + animal.Price * Game.Game.AnimalGanerationModifier
	end

	local total = 1

	if p2 then
		total += Mutations[p2].Modifier
	end

	local flag = false

	if items then
		for _, item in items do
			local trait = Traits[item]

			if not trait then
				continue
			end

			if item == "Sleepy" then
				flag = true
			else
				total += trait.MultiplierModifier
			end
		end
	end

	local v4 = v3 * total

	if flag then
		v4 *= 0.5
	end

	if p3 then
		local Game2 = require(ReplicatedStorage.Shared.Game)
		v4 *= Game2:GetPlayerCashMultiplayer(p3)
	end

	return (math.round(v4))
end

function Animals2:GetGenerationNoTraits(p: string, p2: string?, p3)
	return self:GetGeneration(p, p2, nil, p3)
end

function Animals2:GetPrice(p: string, _)
	return Animals[p].Price
end

function Animals2:GetRarityStringFormat(p: string)
	local rarity = Rarities[p]

	if p == "OG" then
		return "<og>%s</og>"
	elseif p == "Festive" then
		return "<greenred>%s</greenred>"
	end

	if p == "Admin" or p == "Taco" or p == "Spooky" then
		return "<yellowred>%s</yellowred>"
	end

	if p == "Secret" then
		return "<zebra>%s</zebra>"
	elseif p == "Brainrot God" then
		return "<rainbow>%s</rainbow>"
	end

	if rarity then
		return (`<font color="#{rarity.Color:ToHex()}">%s</font>`)
	end

	return "%s"
end

function Animals2:GetAnimalTag(p: string)
	local animal = Animals[p]

	if animal then
		return Animals2:GetRarityStringFormat(animal.Rarity)
	end

	return "%s"
end

function Animals2.GetRarityWeight(_, p: string)
	local rarity = Rarities[p]

	if rarity then
		return rarity.Weight
	end

	return 1
end

function Animals2:GetDisplayName(p: string)
	local animal = Animals[p]

	if animal then
		return animal.DisplayName
	end

	return p
end

function Animals2:ColorBrainrotName(p: string)
	local animalTag = self:GetAnimalTag(p)
	return string.format(animalTag, self:GetDisplayName(p))
end

function Animals2:ColorRecipeName(value: string)
	local v2 = string.split(value, " & ")
	local v3 = {}

	for _, v4 in v2 do
		table.insert(v3, self:ColorBrainrotName(v4))
	end

	return table.concat(v3, " & ")
end

return Animals2