local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local t = require(ReplicatedStorage.Packages.t)
require(ReplicatedStorage.Shared.Modules.ProfileDefaults.Types.Interface)
local TreadmillStaticCover = require(ReplicatedStorage.Client.UI.TreadmillStaticCover)
local TreadmillVideoGate = require(ReplicatedStorage.Client.TreadmillVideoGate)
local TreadmillStaticRateSign = require(ReplicatedStorage.Client.UI.TreadmillStaticRateSign)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
require(ReplicatedStorage.Shared.TreadmillVideoController.Types.Interface)
local Treadmills = require(ReplicatedStorage.Data.Treadmills)
require(script.Parent.Types.Interface)
local treadmills = ReplicatedStorage.Assets.Models.Treadmills
local Render = {
	SetGroundedScale = function(data, p: number)
		t.strict(t.table)(data)
		t.strict(t.number)(p)
		data.Model:ScaleTo(p)
		local root = data.Model.Root
		assert(root:IsA("BasePart"), (`Treadmill "{data.TreadmillId}" Root must be a BasePart`))
		local cframe = data.Model:GetPivot():ToObjectSpace(root.CFrame)
		local groundedToolRootCFrameAtLocation = TreadmillUtil.ResolveGroundedToolRootCFrameAtLocation(
			data.Bottom,
			data.Model
		)
		data.Model:PivotTo(groundedToolRootCFrameAtLocation * cframe:Inverse())
	end
}

function Render.Build(slot: number, ownerUserId: number, p3, p4: number, flag: boolean, parent)
	t.strict(t.number)(slot)
	t.strict(t.number)(ownerUserId)
	t.strict(t.table)(p3)
	t.strict(t.number)(p4)
	t.strict(t.boolean)(flag)
	t.strict(t.instanceIsA("Folder"))(parent)
	local plots = Workspace.Plots
	assert(plots:IsA("Folder"), "Treadmill rendering requires the plots folder")
	local model = plots[tostring(slot)]
	assert(model:IsA("Model"), (`Plot "{slot}" must be a Model`))
	local treadmillBottom = model.TreadmillBottom
	assert(treadmillBottom:IsA("BasePart"), (`Plot "{slot}" TreadmillBottom must be a BasePart`))
	local v = Treadmills.GetByUpgradeLevel(p3.TreadmillUpgradeLevel)
	assert(v ~= nil, (`Invalid treadmill upgrade level {p3.TreadmillUpgradeLevel}`))
	local tool = treadmills[v._id]
	assert(tool:IsA("Tool"), (`Treadmill render template "{v._id}" must be a Tool`))
	local clone = tool:Clone()
	clone.Name = `TreadmillRender_{slot}`

	if TreadmillVideoGate.IsVideoPlayerDisabled() then
		local videoPlayerFolder = TreadmillUtil.FindVideoPlayerFolder(clone)

		if videoPlayerFolder ~= nil then
			videoPlayerFolder:Destroy()
		end
	end

	clone.Parent = parent

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		elseif descendant:IsA("BaseScript") then
			descendant:Destroy()
		end
	end

	local rateSign = TreadmillStaticRateSign.Apply(clone, v.Rarity.Color, v.SpeedMultiplier)
	local videoFeedScreenPart = TreadmillUtil.FindVideoFeedScreenPart(clone)
	local cover

	if flag and videoFeedScreenPart ~= nil then
		cover = TreadmillStaticCover.Create(`StaticTreadmillCover_{slot}`, videoFeedScreenPart)
		TreadmillStaticCover.ApplyFeed(cover, p3.TreadmillMediaFeedState)
	end

	local v4 = {
		Bottom = treadmillBottom,
		Cover = cover,
		Model = clone,
		OwnerUserId = ownerUserId,
		RateSign = rateSign,
		Slot = slot,
		TreadmillId = v._id
	}
	Render.SetGroundedScale(v4, clone:GetScale() * p4)
	return v4
end

return Render