local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local localPlayer = Players.LocalPlayer
local gameSettings = UserSettings().GameSettings
local currentCamera = workspace.CurrentCamera
local Streaming = {}
local v = {
	FruitQuality = {
		Low = 200,
		Medium = 500,
		High = 1000
	},
	RenderQuality = {
		Low = 500,
		Medium = 1000,
		High = 1500
	},
	RenderLimit = {
		Low = 10,
		Medium = 30,
		High = 60
	}
}
local instances = {}
local v2 = {}
local v3 = {}
local ancestors = {}

function GetQualityLevel()
	return gameSettings.SavedQualityLevel.Value
end

local total = 0
local v4 = GetQualityLevel()

function QualityLevelChanged()
	v4 = GetQualityLevel()
end

function IsPlayerWorkshop(p, p2)
	if not (p2.Name ~= p.Name .. "Real Sword" and p2.Name ~= p.Name .. "'s Outline" and p2.Name ~= p.Name .. "ArmamentGroup") then
		return true
	end
end

function RegisterFruit(tool)
	if not tool:IsA("Tool") then
		return
	end

	local fruitModel = tool:FindFirstChild("FruitModel")

	if not fruitModel then
		return
	end

	local animationController = fruitModel:FindFirstChildOfClass("AnimationController")
	local animation = tool:FindFirstChild("Animation")

	if not (animationController and animation) then
		return
	end

	local track = animationController:LoadAnimation(animation)
	v3[tool] = {
		OnUpdate = function()
			local renderDistance = Streaming:GetRenderDistance()
			local position = currentCamera.CFrame.Position
			local v6 = tool:GetPivot().Position - position
			local v7 = math.sqrt(v6.X ^ 2 + v6.Y ^ 2 + v6.Z ^ 2)

			if renderDistance <= v7 and track.IsPlaying then
				track:Stop()
			elseif v7 < renderDistance and not track.IsPlaying then
				track:Play()
			end
		end,
		OnDestroy = function()
			track:Stop()
			track:Destroy()
			track = nil
		end
	}
	return true
end

function IsCharacterHiding()
	if not (RunService:IsClient() and localPlayer.Character) then
		return
	end

	if table.find(ancestors, localPlayer.Character) then
		return true
	end
end

function RegisterDetail(instance)
	if not instance:IsDescendantOf(workspace) or table.find(instances, instance) then
		return
	end

	table.insert(instances, instance)

	if Streaming:IsDescendantOfHiding(instance) then
		Streaming:SetHideEnabled(instance, true)
	end

	RegisterFruit(instance)
end

function UnregisterDetail(p)
	if not table.find(instances, p) then
		return
	end

	table.remove(instances, table.find(instances, p))
	Streaming:SetEnabledDetail(p, true)
	local v5 = v3[p]

	if v5 then
		pcall(v5.OnDestroy)
		table.clear(v5)
		v3[p] = nil
	end
end

function GetRenderDistanceLimit()
	if v4 <= 4 then
		return v.RenderLimit.Low
	end

	if v4 > 4 and v4 <= 7 then
		return v.RenderLimit.Medium
	end

	if v4 > 7 and v4 <= 10 then
		return v.RenderLimit.High
	end

	return v.RenderLimit.Medium
end

function GetRenderDistanceByQuality()
	if v4 <= 4 then
		return v.RenderQuality.Low
	end

	if v4 > 4 and v4 <= 7 then
		return v.RenderQuality.Medium
	end

	if v4 > 7 and v4 <= 10 then
		return v.RenderQuality.High
	end

	return v.RenderQuality.Medium
end

function SetEnabledDetail(folder, flag: boolean, _: boolean)
	if folder:IsA("Model") or folder:IsA("Tool") then
		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("BasePart") or descendant:IsA("Decal") then
				descendant.LocalTransparencyModifier = flag and 0 or 1
			end
		end
	else
		if not folder:IsA("BasePart") then
			return
		end

		folder.LocalTransparencyModifier = flag and 0 or 1
	end
end

function Streaming:GetRenderDistance()
	return Streaming.RenderDistance or GetRenderDistanceByQuality()
end

CollectionService:GetInstanceAddedSignal("Detail"):Connect(RegisterDetail)
CollectionService:GetInstanceRemovedSignal("Detail"):Connect(UnregisterDetail)

function Streaming:RegisterDetail(p)
	return RegisterDetail(p)
end

function Streaming.UnregisterDetail(_, p)
	return UnregisterDetail(p)
end

function Streaming:SetHideEnabled(ancestor, flag: boolean)
	if not ancestor then
		return
	end

	if flag then
		if table.find(ancestors, ancestor) then
			return
		end

		table.insert(ancestors, ancestor)
		Streaming:SetEnabledDetail(ancestor, false)
	else
		local index = table.find(ancestors, ancestor)

		if not index then
			return
		end

		table.remove(ancestors, index)
		SetEnabledDetail(ancestor, true)

		for i = #ancestors, 1, -1 do
			local v5 = ancestors[i]

			if not (v5:IsDescendantOf(ancestor) or not v5:IsDescendantOf(game) or IsPlayerWorkshop(ancestor, v5)) then
				continue
			end

			table.remove(ancestors, i)
			Streaming:SetEnabledDetail(v5, false)
		end

		print(ancestors)
	end
end

function Streaming:SetEnabledDetail(p, flag: boolean, _: boolean)
	v2[p] = not flag or nil
	SetEnabledDetail(p, flag)
end

function Streaming.IsDescendantOfCharacter(_, instance)
	if not (RunService:IsClient() and localPlayer.Character) then
		return
	end

	if instance:IsDescendantOf(localPlayer.Character) then
		return true
	end
end

function Streaming:IsDescendantOfHiding(instance)
	if not RunService:IsClient() or #ancestors <= 0 then
		return
	end

	for _, ancestor in ipairs(ancestors) do
		if instance:IsDescendantOf(ancestor) or IsPlayerWorkshop(ancestor, instance) then
			return true
		end
	end
end

function Streaming.Step(_, p)
	total += p

	if total < 0.1 then
		return
	end

	total = 0
	local position = currentCamera.CFrame.Position
	local renderDistance = GetRenderDistanceByQuality()
	local renderLimits = GetRenderDistanceLimit()
	Streaming.RenderDistance = renderDistance
	Streaming.RenderLimits = renderLimits

	for _, instance in ipairs(instances) do
		if renderLimits <= 0 then
			break
		end

		if not (instance:IsA("Model") or instance:IsA("BasePart") or instance:IsA("Tool")) then
			continue
		end

		if table.find(ancestors, instance) or Streaming:IsDescendantOfHiding(instance) then
			if not v2[instance] then
				Streaming:SetHideEnabled(instance, true)
			end
		else
			local position2 = instance:GetPivot().Position

			if instance:IsA("Model") and not instance.PrimaryPart then
				position2 = instance:GetBoundingBox().Position
			end

			local v7 = position2 - position
			local v8 = math.sqrt(v7.X ^ 2 + v7.Y ^ 2 + v7.Z ^ 2)

			if renderDistance <= v8 and not v2[instance] and renderLimits > 0 then
				renderLimits -= 1
				Streaming:SetEnabledDetail(instance, false)
			elseif v8 < renderDistance and v2[instance] and renderLimits > 0 then
				renderLimits -= 1
				Streaming:SetEnabledDetail(instance, true)
			else
				local v9 = v3[instance]

				if v9 and renderLimits > 0 and v9.OnUpdate then
					v9.OnUpdate()
				end
			end
		end
	end
end

function Streaming.GetQuality(_)
	return GetQualityLevel()
end

function Streaming.Setup(_)
	for _, v5 in pairs(CollectionService:GetTagged("Detail")) do
		Streaming:RegisterDetail(v5)
	end

	gameSettings:GetPropertyChangedSignal("SavedQualityLevel"):Connect(QualityLevelChanged)
end

return Streaming