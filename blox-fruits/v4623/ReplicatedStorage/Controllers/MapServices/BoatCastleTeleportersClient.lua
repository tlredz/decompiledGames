local createVector = vector.create
local BoatCastleTeleportersClient = {}
local Realm = require(game.ReplicatedStorage.Util.Realm)

if Realm.getIfCurrentRealmHasTagAsync("IsThirdSea") == false then
	return BoatCastleTeleportersClient
end

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local v = nil
local v2 = nil
local v3 = nil
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}

function BoatCastleTeleportersClient.renderTeleportersWithName(p: string)
	local v8 = v4[p]
	local serverInfo = v8 and v8.serverInfo
	local v9 = v5[p]

	if not (v8 and serverInfo and v9 and serverInfo.MeshVertexColor) then
		return
	end

	local vertexColor = not v8.isUnlocked and createVector(0.5, 0.5, 0.5) or serverInfo.MeshVertexColor

	for _, v11 in v9 do
		local color = v11:FindFirstChild("Color")
		local mesh = color and color:FindFirstChild("Mesh")

		if not (color and color:IsA("Part") and mesh and mesh:IsA("SpecialMesh")) then
			continue
		end

		color.Color = Color3.new(vertexColor.X, vertexColor.Y, vertexColor.Z)
		mesh.VertexColor = vertexColor

		for _, part in v11:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			if part.Name == "Part" then
				local mesh2 = part:FindFirstChild("Mesh")

				if mesh2 and mesh2:IsA("SpecialMesh") then
					mesh2.VertexColor = vertexColor
				end
			end

			local oldTransparency = part:GetAttribute("oldTransparency")
			local transparency

			if typeof(oldTransparency) == "number" then
				transparency = oldTransparency
			else
				transparency = part.Transparency
			end

			if typeof(oldTransparency) ~= "number" then
				part:SetAttribute("oldTransparency", transparency)
			end

			part.Transparency = transparency
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function registerHitbox(p)
	local name = p.Name
	p.Hitbox.Touched:Connect(function(otherPart)
		if (v6[name] or 0) > tick() then
			return
		end

		local character = Players.LocalPlayer.Character

		if not character or otherPart.Parent ~= character then
			return
		end

		local v8 = v4[name]

		if not v8 then
			return
		end

		v6[name] = tick() + 4

		if not v8.isUnlocked then
			v.new("<Color=Red>You cannot access this portal yet.<Color=/>"):Display()
			return
		end

		if v2(character) then
			v.new("<Color=Red>Cannot teleport while transformed.<Color=/>"):Display()
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local currentCamera = workspace.CurrentCamera

		if not (humanoidRootPart and currentCamera) then
			return
		end

		local blackscreen = Players.LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Blackscreen")
		blackscreen.BackgroundTransparency = 0
		blackscreen.Position = UDim2.new(-1, 0, 0, -50)
		blackscreen:TweenPosition(UDim2.new(0, 0, 0, -50), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.3)
		task.wait(0.3)
		local v9 = character:GetPivot():Inverse() * currentCamera.CFrame
		pcall(function()
			local v10 = nil

			for _, v11 in v5[name] do
				if v11 ~= p then
					v10 = v11
				end
			end

			assert(v10, "target teleporter not found")
			local pivot = v10:GetAttribute("Pivot")
			assert(typeof(pivot) == "CFrame", "target teleporter pivot missing")
			humanoidRootPart.CFrame = pivot

			if v3:InvokeServer("InitiateTeleport", p) then
				task.wait()
				currentCamera.CFrame = character:GetPivot() * v9
				humanoidRootPart.CFrame = pivot
			end

			task.wait(0.3)
		end)
		v6[name] = tick() + 4
		blackscreen:TweenPosition(UDim2.new(1, 0, 0, -50), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.3)
	end)
end

local function getInfoForTeleporter(p: string)
	local result

	while true do
		local success
		success, result = pcall(function()
			return v3:InvokeServer("GetInfo", p)
		end)

		if success and typeof(result) == "table" and typeof(result.isUnlocked) == "boolean" then
			break
		end

		task.wait(0.5)
	end

	v4[p] = result
	BoatCastleTeleportersClient.renderTeleportersWithName(p)
end

function BoatCastleTeleportersClient.findAndLoadPairs()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function onTeleporterAddedOrStreamed(model)
		task.delay(0.25, function()
			if not model:IsA("Model") then
				return
			end

			local hitbox = model:FindFirstChild("Hitbox")
			local color = model:FindFirstChild("Color")
			local mesh = color and color:FindFirstChild("Mesh")

			if not (hitbox and hitbox:IsA("Part") and color and color:IsA("Part") and mesh and mesh:IsA("SpecialMesh")) then
				return
			end

			local v8 = model

			if v7[v8] then
				return
			end

			local name = v8.Name
			local v9 = v5[name]

			if not v9 then
				v9 = {}
				v5[name] = v9
				task.spawn(getInfoForTeleporter, name)
			end

			table.insert(v9, v8)
			registerHitbox(v8) -- equivalent call inferred; original call site unknown
			v7[v8] = true
			BoatCastleTeleportersClient.renderTeleportersWithName(name)
		end)
	end

	CollectionService:GetInstanceAddedSignal("BoatCastleTeleporter"):Connect(onTeleporterAddedOrStreamed)

	for _, v8 in CollectionService:GetTagged("BoatCastleTeleporter") do
		onTeleporterAddedOrStreamed(v8) -- equivalent call inferred; original call site unknown
	end

	return v5
end

function BoatCastleTeleportersClient.OnStart()
	local Net = require(game.ReplicatedStorage.Modules.Net)
	v3 = Net:RemoteFunction("BoatCastleTeleporters")
	Net:RemoteEvent("BoatCastleTeleportersRefresh").OnClientEvent:Connect(function()
		for k in v5 do
			task.spawn(getInfoForTeleporter, k)
		end
	end)
	local Notification = require(game.ReplicatedStorage:WaitForChild("Notification"))
	v = Notification
	local IsTransformed = require(game.ReplicatedStorage.Util.IsTransformed)
	v2 = IsTransformed
	BoatCastleTeleportersClient.findAndLoadPairs()
end

return BoatCastleTeleportersClient