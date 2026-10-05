local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Types.AssetItem)
local Assets = require(ReplicatedStorage.Data.Assets)
local directory = Assets.Directory
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
require(ReplicatedStorage.Shared.Types.FuseMachine)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local Trove = require(ReplicatedStorage.Packages.Trove)
local FuseMachineSelectedSlot = {}
FuseMachineSelectedSlot.__index = FuseMachineSelectedSlot
FuseMachineSelectedSlot.__class = "FuseMachineSelectedSlot"

function FuseMachineSelectedSlot.new(slot, uid: string, p, callback)
	local object = setmetatable({}, FuseMachineSelectedSlot)
	object._slot = slot
	object._trove = Trove.new()
	object._uid = uid
	local full = slot.Full
	slot.Empty.Visible = false
	full.Visible = true
	object._trove:Add(function()
		full.Visible = false
		slot.Empty.Visible = true
	end)
	local v = directory[p.Category]
	assert(v ~= nil, (`Missing asset config {p.Category}`))
	local name = full:FindFirstChild("Name")
	local v2

	if name == nil then
		v2 = false
	else
		v2 = name:IsA("TextLabel")
	end

	assert(v2, "Fuse input Full.Name must be a TextLabel")
	name.Text = v.DisplayName
	local pet = full.Pet
	assert(pet:IsA("ImageLabel"), "Fuse input Full.Pet must be an ImageLabel")
	pet.Image = v.Icon or ""
	object:_applyMutation(p)
	object:_applyRarity(p)
	local add = full.Add
	assert(add:IsA("ImageButton"), "Fuse input Full.Add must be an ImageButton")
	object._trove:Add(add.Activated:Connect(function()
		callback(uid)
	end))
	ButtonFX(add, 1.08)
	return object
end

function FuseMachineSelectedSlot:_applyMutation(p2)
	local baseMutation = p2.BaseMutation or p2.Mutations[1]

	if baseMutation == nil or baseMutation == Mutations.NO_MUTATION then
		return
	end

	local name = self._slot.Full:FindFirstChild("Name")
	local v

	if name == nil then
		v = false
	else
		v = name:IsA("TextLabel")
	end

	assert(v, "Fuse input Full.Name must be a TextLabel")
	local v2 = Mutations.Get(baseMutation)
	name.Text = `{Mutations.LabelOf(baseMutation)} {name.Text}`

	if v2 then
		name.TextColor3 = v2.Tint
	end
end

function FuseMachineSelectedSlot:_applyRarity(p2)
	local rarity = self._slot.Full.Rarity
	assert(rarity:IsA("TextLabel"), "Fuse input Full.Rarity must be a TextLabel")
	local v = directory[p2.Category]
	assert(v ~= nil, (`Missing asset config {p2.Category}`))

	for _, uIGradient in ipairs(rarity:GetChildren()) do
		if uIGradient:IsA("UIGradient") then
			uIGradient:Destroy()
		end
	end

	rarity.Text = v.Rarity.DisplayName
	rarity.TextColor3 = v.Rarity.Color

	if v.Rarity.RarityGradient then
		local clone = v.Rarity.RarityGradient:Clone()
		clone.Parent = rarity
	end
end

function FuseMachineSelectedSlot:GetUid()
	return self._uid
end

function FuseMachineSelectedSlot:Destroy()
	self._trove:Destroy()
end

return FuseMachineSelectedSlot