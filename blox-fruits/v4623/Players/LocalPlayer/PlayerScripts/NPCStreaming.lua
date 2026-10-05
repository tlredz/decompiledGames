local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Graphics = require(ReplicatedStorage.Util.Graphics)
local LimbFlicker = require(ReplicatedStorage.Util.LimbFlicker)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag(script.Name):traceback():build()
local enemies = workspace:WaitForChild("Enemies")
local characters = workspace:WaitForChild("Characters")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local v2 = {}
local info = v.info

function tryReduceCharacterResolution(p)
	info((`trying to init low-res character "{p.Model:GetFullName()}"`))

	if p.Model:FindFirstChild("Summoner") then
		return false
	end

	local proxy_Shirt = p.Model:WaitForChild("Proxy_Shirt", 1)
	local shirt = p.Model:FindFirstChildWhichIsA("Shirt")

	if proxy_Shirt and proxy_Shirt:IsA("StringValue") and shirt then
		shirt.ShirtTemplate = Graphics.SmartScale(proxy_Shirt:GetAttribute("ShirtTemplate"))
		shirt.Color3 = proxy_Shirt:GetAttribute("Color3")
	end

	local proxy_Pants = p.Model:WaitForChild("Proxy_Pants", 1)
	local pants = p.Model:FindFirstChildWhichIsA("Pants")

	if proxy_Pants and proxy_Pants:IsA("StringValue") and pants then
		pants.PantsTemplate = Graphics.SmartScale(proxy_Pants:GetAttribute("PantsTemplate"))
		pants.Color3 = proxy_Pants:GetAttribute("Color3")
	end

	local faceId = p.Model:GetAttribute("FaceId")
	local head = p.Model:FindFirstChild("Head")

	if head and head:IsA("BasePart") then
		local face = head:FindFirstChild("face")

		if face and face:IsA("Decal") and faceId then
			face.Texture = Graphics.SmartScale(faceId)
		end
	end

	LimbFlicker.fix(p.Model)

	for _, child in pairs(p.Model:GetChildren()) do
		if not (child:IsA("Accessory") or child:IsA("Hat")) then
			continue
		end

		for _, descendant in pairs(child:GetDescendants()) do
			if descendant.Name ~= "Proxy_SpecialMesh" then
				continue
			end

			local parent = descendant.Parent

			if not parent then
				continue
			end

			local specialMesh = parent:FindFirstChildWhichIsA("SpecialMesh")

			if not specialMesh then
				continue
			end

			for _, attributeName in {
				"MeshId",
				"MeshType",
				"Offset",
				"Scale",
				"TextureId",
				"VertexColor"
			} do
				local attribute = descendant:GetAttribute(attributeName)

				if attributeName == "TextureId" then
					attribute = Graphics.SmartScale(attribute)
				end

				specialMesh[attributeName] = attribute
			end
		end
	end

	return true
end

function tryHideEnemyCharacter(instance)
	info((`trying to hide enemy "{instance:GetFullName()}"`))

	if v2[instance] or not instance:WaitForChild("CharacterReady", 7.5) or v2[instance] then
		return false
	end

	local head = instance:WaitForChild("Head", 1)

	if not head then
		return false
	end

	assert(head and head:IsA("BasePart"))
	v2[instance] = {
		Model = instance,
		Root = head,
		IsRendered = true
	}
	return tryReduceCharacterResolution(v2[instance])
end

info("initializing enemies folder")
enemies.ChildAdded:Connect(tryHideEnemyCharacter)

for _, child in ipairs(enemies:GetChildren()) do
	local v3 = child
	task.spawn(function()
		tryHideEnemyCharacter(v3)
	end)
end

local CollectionService = game:GetService("CollectionService")

for _, v3 in CollectionService:GetTagged("ProxyRig") do
	tryHideEnemyCharacter(v3)
end

local CollectionService2 = game:GetService("CollectionService")
CollectionService2:GetInstanceAddedSignal("ProxyRig"):Connect(function(p)
	tryHideEnemyCharacter(p)
end)
local now = 0
RunService.Heartbeat:Connect(function(_: number)
	if tick() - now < 0.25 then
		return
	end

	now = tick()
	local character = Players.LocalPlayer.Character
	local v3 = character and (character.Parent == characters or character:IsDescendantOf(_WorldOrigin))
	local position = workspace.CurrentCamera.CFrame.Position

	for k, v4 in pairs(v2) do
		if v4.Model and v4.Model.Parent then
			local v5 = (v4.Root.Position - position).Magnitude > 1200 or v3 == false
			local v6 = not v4.IsRendered and v4.Model:GetAttribute("DoNotRender") and true or v5

			if v4.IsRendered and v6 and not (v4.Model.Name:match("Leviathan") or v4.Model:GetAttribute("DisableDistanceCulling")) then
				v4.IsRendered = false
				task.wait()
				v4.Model.Parent = ReplicatedStorage

				if not v4.Model:FindFirstChild("Summoner") then
					local shirt = v4.Model:FindFirstChildWhichIsA("Shirt")

					if shirt then
						shirt.ShirtTemplate = ""
					end

					local pants = v4.Model:FindFirstChildWhichIsA("Pants")

					if pants then
						pants.PantsTemplate = ""
					end

					local head = v4.Model:FindFirstChild("Head")
					local decal = head and head:FindFirstChildWhichIsA("Decal") and head:FindFirstChildWhichIsA("Decal")

					if decal then
						decal.Texture = ""
					end

					for _, child in pairs(v4.Model:GetChildren()) do
						if not (child:IsA("Accessory") or child:IsA("Hat")) then
							continue
						end

						for _, specialMesh in pairs(child:GetDescendants()) do
							if not specialMesh:IsA("SpecialMesh") then
								continue
							end

							specialMesh.TextureId = ""
							specialMesh.MeshId = ""
						end
					end
				end
			elseif v4.IsRendered == false and v6 == false then
				v4.IsRendered = true
				tryReduceCharacterResolution(v4)
				task.wait()
				v4.Model.Parent = enemies
			end
		else
			v2[k] = nil
			local v5 = v4
			task.delay(5, function()
				local model = v5.Model
				pcall(function()
					if model then
						model:Destroy()
					end
				end)
			end)
		end
	end
end)