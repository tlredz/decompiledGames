local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local currentCamera = Workspace.CurrentCamera
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local revive = FX:WaitForChild("Revive")

local function cameraShakeAt(vector: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 300) > (currentCamera.CFrame.p - vector).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

function EmitAll(items)
	local function Emit(folder)
		for _, emitter in ipairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter:GetAttribute("EmitDelay") then
				local v = emitter
				task.delay(emitter:GetAttribute("EmitDelay"), function()
					v:Emit(v:GetAttribute("EmitCount"))
				end)
			else
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end

	if typeof(items) ~= "table" then
		Emit(items)
		return
	end

	for _, item in items do
		Emit(item)
	end
end

local v = {}
Workspace.Enemies.ChildRemoved:Connect(function(child)
	if v[child] then
		if v[child].Connection then
			v[child].Connection:Disconnect()
		end

		v[child] = nil
	end
end)
Workspace.Characters.ChildRemoved:Connect(function(child)
	if v[child] then
		if v[child].Connection then
			v[child].Connection:Disconnect()
		end

		v[child] = nil
	end
end)
local v2 = {
	Default = {
		HighlightFill = Color3.fromRGB(75, 255, 228),
		HighlightOutline = Color3.fromRGB(181, 254, 255)
	},
	Red = {
		HighlightFill = Color3.fromRGB(255, 75, 75),
		HighlightOutline = Color3.fromRGB(214, 19, 23)
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getGhostColorOwner(data, parent)
	local TryGetColorFolderParent = require(ReplicatedStorage.Modules.TryGetColorFolderParent)
	return TryGetColorFolderParent(data) or TryGetColorFolderParent({
		Character = parent
	})
end

local function RecolorGhostColor(p, p2)
	if p == nil then
		return p2
	end

	return Util.WrapColor3Constructor(p2, p, "GhostFruitVFXColor")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ParentWithGhostColor(clone, parent, ghostColorOwner)
	if ghostColorOwner == nil then
		clone.Parent = parent
	else
		Util.SetParentOverrideWithColor(clone, parent, ghostColorOwner, "GhostFruitVFXColor")
	end
end

return function(data)
	local hrp = data.hrp
	local duration = data.Duration or 1
	local parent = hrp.Parent
	local ghostColorOwner = getGhostColorOwner(data, parent) -- equivalent call inferred; original call site unknown
	local v3 = v2[data.Color or "Default"]

	if data.Enabled then
		local magnitude = (hrp.Position - currentCamera.CFrame.Position).Magnitude

		if magnitude < 600 then
			local position = hrp.Position
			local v4 = 7 or 8
			local v5 = 12 or 14
			local v6 = 0.2
			local v7 = 0.6 or 0.7

			if (75 or 300) > (currentCamera.CFrame.p - position).Magnitude then
				Util.CameraShaker:ShakeOnce(v4, v5, v6, v7)
			end

			if data.HideEffect then
				local clone = revive["Wandering Soul"]["StartUp/End"]:Clone()
				clone.CFrame = hrp.CFrame
				ParentWithGhostColor(clone, _WorldOrigin, ghostColorOwner) -- equivalent call inferred; original call site unknown
				EmitAll(clone)
				Util.Debris:AddItem(clone, 2)
			else
				local clone = revive.StartUpPossession:Clone()
				clone.CFrame = hrp.CFrame
				ParentWithGhostColor(clone, _WorldOrigin, ghostColorOwner) -- equivalent call inferred; original call site unknown
				EmitAll(clone)
				Util.Debris:AddItem(clone, 3)
			end
		elseif magnitude > 2100 and not data.Permanent then
			return
		end

		if not v[parent] then
			v[parent] = {
				Highlights = {},
				Connection = nil
			}
		end

		local models = { parent }

		-- equivalent calls inferred from this helper; original call sites unknown
		local function alreadyFound(model)
			for _, v4 in pairs(models) do
				if model == v4 then
					return true
				end
			end
		end

		for _, model in _WorldOrigin.PlayerAccessoriesProxy:GetChildren() do
			if not (model:IsA("Model") and model.PrimaryPart) then
				continue
			end

			-- equivalent call inferred; original call site unknown
			if alreadyFound(model) then
				continue
			end

			for _, motor6D in pairs(model.PrimaryPart:GetChildren()) do
				if motor6D:IsA("Motor6D") and motor6D.Part0:IsDescendantOf(parent) then
					table.insert(models, model)
				end
			end
		end

		local flag = true

		for _, highlight in pairs(v[parent].Highlights) do
			if not (highlight:GetAttribute("Permanent") or highlight:GetAttribute("V") and not data.V or highlight:GetAttribute("F") and not data.F or highlight:GetAttribute("Z") and not data.Z) then
				continue
			end

			flag = false
		end

		if flag then
			if v[parent].Connection then
				v[parent].Connection:Disconnect()
			end

			for k, highlight in pairs(v[parent].Highlights) do
				highlight:Destroy()
				v[parent].Highlights[k] = nil
			end

			for _, parent2 in pairs(models) do
				local highlight = Instance.new("Highlight")
				local highlightFill = v3.HighlightFill

				if ghostColorOwner ~= nil then
					highlightFill = Util.WrapColor3Constructor(highlightFill, ghostColorOwner, "GhostFruitVFXColor")
				end

				highlight.FillColor = highlightFill
				local highlightOutline = v3.HighlightOutline

				if ghostColorOwner ~= nil then
					highlightOutline = Util.WrapColor3Constructor(
						highlightOutline,
						ghostColorOwner,
						"GhostFruitVFXColor"
					)
				end

				highlight.OutlineColor = highlightOutline
				highlight.FillTransparency = 1
				highlight.OutlineTransparency = 1
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.Parent = parent2
				TweenService:Create(highlight, TweenInfo.new(duration), {
					FillTransparency = 0.6,
					OutlineTransparency = 0.4
				}):Play()
				table.insert(v[parent].Highlights, highlight)
			end

			v[parent].Connection = parent.Destroying:Connect(function()
				if v[parent] then
					v[parent].Connection:Disconnect()
					v[parent] = nil
				end
			end)
		end

		for _, highlight in pairs(v[parent].Highlights) do
			if typeof(data.Permanent) == "boolean" then
				highlight:SetAttribute("Permanent", data.Permanent)
			end

			if typeof(data.Z) == "boolean" then
				highlight:SetAttribute("Z", data.Z)
			end

			if typeof(data.V) == "boolean" then
				highlight:SetAttribute("V", data.V)
			end

			if typeof(data.F) == "boolean" then
				highlight:SetAttribute("F", data.F)
			end
		end
	else
		if not v[parent] then
			return
		end

		if (hrp.Position - currentCamera.CFrame.Position).Magnitude < 600 then
			local position = hrp.Position
			local v4 = 7 or 8
			local v5 = 12 or 14
			local v6 = 0.2
			local v7 = 0.6 or 0.7

			if (75 or 300) > (currentCamera.CFrame.p - position).Magnitude then
				Util.CameraShaker:ShakeOnce(v4, v5, v6, v7)
			end

			if data.HideEffect then
				local clone = revive["Wandering Soul"]["StartUp/End"]:Clone()
				clone.CFrame = hrp.CFrame
				ParentWithGhostColor(clone, _WorldOrigin, ghostColorOwner) -- equivalent call inferred; original call site unknown
				EmitAll(clone)
				Util.Debris:AddItem(clone, 2)
			else
				local clone = revive.StartUpPossession:Clone()
				clone.CFrame = hrp.CFrame
				ParentWithGhostColor(clone, _WorldOrigin, ghostColorOwner) -- equivalent call inferred; original call site unknown
				EmitAll(clone)
				Util.Debris:AddItem(clone, 3)
			end
		end

		for _, highlight in pairs(v[parent].Highlights) do
			if typeof(data.Permanent) == "boolean" then
				highlight:SetAttribute("Permanent", data.Permanent)
			end

			if typeof(data.Z) == "boolean" then
				highlight:SetAttribute("Z", data.Z)
			end

			if typeof(data.V) == "boolean" then
				highlight:SetAttribute("V", data.V)
			end

			if typeof(data.F) == "boolean" then
				highlight:SetAttribute("F", data.F)
			end
		end

		local flag = true

		for _, highlight in pairs(v[parent].Highlights) do
			if highlight:GetAttribute("Permanent") or (highlight:GetAttribute("V") or highlight:GetAttribute("F") or highlight:GetAttribute("Z")) and not (data.V and data.F and data.Z) then
				flag = false
			else
				TweenService:Create(highlight, TweenInfo.new(duration), {
					FillTransparency = 1,
					OutlineTransparency = 1
				}):Play()
				Util.Debris:AddItem(highlight, duration)
			end
		end

		if flag then
			if v[parent].Connection then
				v[parent].Connection:Disconnect()
			end

			v[parent] = nil
		end
	end
end