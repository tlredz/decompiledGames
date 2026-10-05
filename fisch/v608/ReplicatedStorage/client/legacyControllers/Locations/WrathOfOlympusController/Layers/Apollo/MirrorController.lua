local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages.Net)
local Observers = require(packages.Observers)
local Trove = require(packages.Trove)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local remoteFunction = Net:RemoteFunction("Apollo/Mirror")
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local v = false
local v2 = {}

local function setSingleMirrorState(model, flag: boolean)
	local attachment = CollectionService:GetTagged("ApolloDivineSealAttachment")[1]

	if not (model:IsA("Model") and model.PrimaryPart) then
		return
	end

	local mirrorPart = model:FindFirstChild("MirrorPart")
	local mirrorAttachment = mirrorPart and mirrorPart:FindFirstChild("MirrorAttachment")

	if not flag then
		GeneralUtils.pivotTween(model, tweenInfo, model:GetAttribute("OriginalCFrame"))
	end

	if model:FindFirstChildOfClass("ProximityPrompt") then
		local proximityPrompt = model:FindFirstChildOfClass("ProximityPrompt")
		proximityPrompt.Enabled = not flag
	end

	if attachment and mirrorAttachment then
		if flag then
			local clone = script.Beam:Clone()
			clone.Parent = mirrorPart
			clone.Attachment0 = mirrorAttachment
			clone.Attachment1 = attachment
			clone.Brightness = 5.5
			GeneralUtils.fastTween(clone, TweenInfo.new(2, Enum.EasingStyle.Linear), {
				Brightness = 1.5
			})
		elseif mirrorPart:FindFirstChild("Beam") then
			mirrorPart:FindFirstChild("Beam"):Destroy()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetMirrorState(flag: boolean)
	if v == flag then
		return
	end

	v = flag

	for _, v3 in CollectionService:GetTagged("ApolloMirror") do
		setSingleMirrorState(v3, flag)
	end
end

return {
	Start = function(_)
		Observers.observeTag("ApolloMirror", function(model)
			if not model:IsA("Model") then
				return
			end

			local mirrorId = model:GetAttribute("MirrorId")
			local correctRotation = model:GetAttribute("CorrectRotation")

			if not (mirrorId and correctRotation) or not model.PrimaryPart or model:FindFirstChildOfClass("ProximityPrompt") then
				return
			end

			if model:GetAttribute("OriginalCFrame") then
				model:PivotTo(model:GetAttribute("OriginalCFrame") * CFrame.Angles(0, math.rad(v2[mirrorId] or 0), 0))
			else
				model:SetAttribute("OriginalCFrame", model:GetPivot())
			end

			local maid = Trove.new()
			maid:AttachToInstance(model)
			local _, v3, _ = model:GetPivot():ToEulerAnglesYXZ()
			local v4 = math.round((math.deg(v3))) % 360
			local flag = false
			local v5 = maid:Add(Instance.new("ProximityPrompt"))
			v5.Style = Enum.ProximityPromptStyle.Custom
			v5.ActionText = "Rotate"
			v5.ObjectText = "Mirror"
			v5.HoldDuration = 0
			v5.RequiresLineOfSight = false
			v5.Parent = model
			local v6 = nil
			maid:Add(v5.Triggered:Connect(function()
				v4 = (v4 + 45) % 360
				v2[mirrorId] = v4

				if v6 then
					v6:Cancel()
					v6 = nil
				end

				v6 = GeneralUtils.pivotTween(
					model,
					tweenInfo,
					model:GetPivot() * CFrame.Angles(0, 0.7853981633974483, 0)
				)
				v6:Play()
				v5.Enabled = false
				task.delay(v6.TweenInfo.Time, function()
					if not v then
						v5.Enabled = true
					end
				end)

				if v4 == correctRotation then
					flag = true

					if remoteFunction:InvokeServer(mirrorId, true) == "all_aligned" then
						SetMirrorState(true) -- equivalent call inferred; original call site unknown
					end
				elseif flag then
					remoteFunction:InvokeServer(mirrorId, false)
				end
			end))
			setSingleMirrorState(model, v)
			return function()
				maid:Destroy()
			end
		end)

		remoteFunction.OnClientInvoke = function()
			if v == false then
				return
			end

			v = false

			for _, v3 in CollectionService:GetTagged("ApolloMirror") do
				setSingleMirrorState(v3, false)
			end
		end
	end
}