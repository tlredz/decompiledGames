local FamilyController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local FamilyPlayer = require(script.FamilyPlayer)
FamilyController.FamilyStateChanged = Signal.new()
FamilyController.HideInvitesChanged = Signal.new()
local v = false
local v2 = false
local v3 = nil
local v4 = {}

function FamilyController.FrameworkInit() end

function FamilyController.FrameworkStart()
	Remotes.connect("FamilyStateChanged", function(options)
		v3 = options
		FamilyController.FamilyStateChanged:Fire(options)
		local v5 = {}

		for _, v6 in options or {} do
			v5[v6.player] = {
				role = v6.role
			}
		end

		for k in v4 do
			if v5[k] then
				continue
			end

			v4[k]:Destroy()
			v4[k] = nil
		end

		for k, v6 in v5 do
			if v4[k] then
				v4[k]:UpdateRole(v6.role)
			else
				v4[k] = FamilyPlayer.new(k, v6.role, v2)
			end
		end
	end)
	local v5 = Remotes.invokeServer("GetFamilyState")

	if v5 then
		v3 = v5
		FamilyController.FamilyStateChanged:Fire(v3)
	end

	v = FamilyController.AreInvitesHidden()
	FamilyController.HideInvitesChanged:Fire(v)
end

function FamilyController.ToggleHideInvites()
	v = not v
	FamilyController.HideInvitesChanged:Fire(v)
end

function FamilyController.ToggleHideFamily()
	v2 = not v2

	for _, v5 in v4 do
		v5:SetHidden(v2)
	end
end

function FamilyController.AreInvitesHidden()
	return v
end

function FamilyController.IsFamilyHidden()
	return v2
end

function FamilyController.IsPlayerInFamily(p)
	if not v3 then
		return false
	end

	for _, v5 in v3 do
		if v5.player == p then
			return true
		end
	end

	return false
end

function FamilyController.GetFamilyState()
	return v3
end

return FamilyController