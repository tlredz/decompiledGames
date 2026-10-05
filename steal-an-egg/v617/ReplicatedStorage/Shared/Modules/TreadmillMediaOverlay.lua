local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local t = require(ReplicatedStorage.Packages.t)

local function typecheckAssertion(callback)
	return function(p)
		local v, v2 = callback(p)
		assert(v, v2)
		return p
	end
end

local function typecheckChecker(callback)
	return function(p)
		local success, result = pcall(callback, p)

		if success then
			return success, nil
		end

		return success, (tostring(result))
	end
end

require(ReplicatedStorage.Shared.Globals.Constants)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TreadmillMediaCatalog = require(ReplicatedStorage.Data.TreadmillMediaCatalog)
local TreadmillMediaIdentity = require(ReplicatedStorage.Shared.Modules.TreadmillMediaIdentity)
local Media = require(ReplicatedStorage.Shared.TreadmillVideoController.Media)
require(ReplicatedStorage.Shared.TreadmillVideoController.Types.Interface)
local replicated = FastFlags.Replicated
local boolean = t.boolean
local v = replicated("Game.TreadmillDynamicMedia.Enabled", function(p)
	local v2, v3 = boolean(p)
	assert(v2, v3)
	return p
end, true)
local v2 = {}
local v3 = {
	Brainrot = true,
	Funny = true,
	Satisfying = true,
	WeirdOrHorror = true,
	Music = true
}
local revision = 0
local additions = {}
local v4 = {}
local additionsByMediaKey = {}
local v5 = {}
local v6 = nil

for _, v7 in ipairs(Media) do
	if v7.Disabled == true then
		v2[TreadmillMediaIdentity.GetMediaKey(v7)] = true
	end
end

local TreadmillMediaOverlay = {
	Changed = Signal.new()
}

local function sanitizeAddition(addition)
	if type(addition) ~= "table" or (addition.Kind ~= "Video" or type(addition.Video) ~= "string") then
		return nil
	end

	if type(addition.MediaKey) ~= "string" or addition.MediaKey == "" or (type(addition.BucketType) ~= "string" or v3[addition.BucketType] ~= true) then
		return nil
	end

	if type(addition.Duration) ~= "number" or addition.Duration <= 0 then
		return nil
	end

	if type(addition.AddedAt) ~= "number" or type(addition.AddedBy) ~= "number" then
		return nil
	end

	if addition.CoverImage == nil or type(addition.CoverImage) == "string" then
		return {
			MediaKey = addition.MediaKey,
			Kind = "Video",
			Video = addition.Video,
			CoverImage = addition.CoverImage,
			BucketType = addition.BucketType,
			Duration = addition.Duration,
			AddedAt = addition.AddedAt,
			AddedBy = addition.AddedBy
		}
	end

	return nil
end

local function compareAdditions(p, p2)
	if p.AddedAt == p2.AddedAt then
		return p.MediaKey < p2.MediaKey
	end

	return p.AddedAt < p2.AddedAt
end

local function applySanitizedSnapshot(data)
	revision = data.Revision
	additions = data.Additions
	v4 = {}

	for k in pairs(data.Exclusions) do
		v4[k] = true
	end

	additionsByMediaKey = {}

	for _, addition in ipairs(additions) do
		additionsByMediaKey[addition.MediaKey] = addition
	end

	for i, addition in ipairs(additions) do
		local releaseVersion = TreadmillMediaCatalog.CURRENT_RELEASE_VERSION + i
		local v8 = v5[addition.MediaKey]

		if v8 == nil then
			v5[addition.MediaKey] = {
				Kind = "Video",
				ReleaseVersion = releaseVersion,
				BucketType = addition.BucketType,
				Video = addition.Video,
				CoverImage = addition.CoverImage,
				Duration = addition.Duration
			}
		else
			v8.ReleaseVersion = releaseVersion
		end
	end

	TreadmillMediaOverlay.Changed:Fire()
end

function TreadmillMediaOverlay.SanitizeSnapshot(data)
	if type(data) ~= "table" or (type(data.Revision) ~= "number" or data.Revision < 0) then
		return nil
	end

	local additions2 = {}
	local v8 = {}

	if type(data.Additions) == "table" then
		for _, addition in ipairs(data.Additions) do
			local v9 = sanitizeAddition(addition)

			if v9 == nil or v8[v9.MediaKey] then
				continue
			end

			v8[v9.MediaKey] = true
			table.insert(additions2, v9)
		end
	end

	table.sort(additions2, compareAdditions)
	local exclusions = {}

	if type(data.Exclusions) == "table" then
		for k, exclusion in pairs(data.Exclusions) do
			if not (type(k) == "string" and type(exclusion) == "table") then
				continue
			end

			exclusions[k] = {
				At = type(exclusion.At) ~= "number" and 0 or exclusion.At,
				By = type(exclusion.By) ~= "number" and 0 or exclusion.By
			}
		end
	end

	return {
		Revision = math.floor(data.Revision),
		Additions = additions2,
		Exclusions = exclusions
	}
end

function TreadmillMediaOverlay.ApplySnapshot(p)
	local v7 = TreadmillMediaOverlay.SanitizeSnapshot(p)

	if v7 == nil then
		return
	end

	v6 = v7

	if not (v:Get() and v7.Revision ~= revision) then
		return
	end

	applySanitizedSnapshot(v7)
end

function TreadmillMediaOverlay.ApplyTo(list)
	if #additions == 0 then
		return 0
	end

	local v7 = {}

	for _, v8 in ipairs(list) do
		v7[TreadmillMediaIdentity.GetMediaKey(v8)] = true
	end

	local count = 0

	for _, addition in ipairs(additions) do
		if v7[addition.MediaKey] then
			continue
		end

		v7[addition.MediaKey] = true
		table.insert(list, v5[addition.MediaKey])
		count += 1
	end

	return count
end

function TreadmillMediaOverlay.IsExcluded(p: string)
	if v2[p] then
		return true
	end

	if v:Get() then
		return v4[p] == true
	end

	return false
end

function TreadmillMediaOverlay.GetCurrentReleaseVersion()
	return TreadmillMediaCatalog.CURRENT_RELEASE_VERSION + #additions
end

function TreadmillMediaOverlay.GetRevision()
	return revision
end

function TreadmillMediaOverlay.GetAdditionByKey(p: string)
	return additionsByMediaKey[p]
end

function TreadmillMediaOverlay.GetAdditions()
	return additions
end

function TreadmillMediaOverlay.GetEntryByKey(p: string)
	return v5[p]
end

function TreadmillMediaOverlay.GetReplicationSnapshot()
	return v6
end

v.Changed:Connect(function()
	local v7 = v6

	if v:Get() and v7 ~= nil and v7.Revision ~= revision then
		applySanitizedSnapshot(v7)
	end
end)

if RunService:IsClient() then
	local Remotes = require(ReplicatedStorage.Shared.Remotes)
	Remotes.Treadmill.OverlaySnapshot.OnClientEvent:Connect(function(p)
		TreadmillMediaOverlay.ApplySnapshot(p)
	end)
end

return TreadmillMediaOverlay