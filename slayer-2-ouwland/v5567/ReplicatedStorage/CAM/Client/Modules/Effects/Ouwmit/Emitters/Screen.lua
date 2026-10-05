local createVector = vector.create
local Players = game:GetService("Players")
local utilities = script.Parent.Parent.Utilities
require(utilities.Types)
local OuwmitUtility = require(utilities.OuwmitUtility)
local Animator = require(utilities.Animator)
local object = setmetatable({}, {
	__mode = "k"
})

local function isLocalViewer(player)
	if typeof(player) ~= "Instance" then
		return false
	end

	local localPlayer = Players.LocalPlayer

	if localPlayer == nil then
		return false
	end

	if player:IsA("Player") then
		return player == localPlayer
	end

	local character = localPlayer.Character

	if character == nil then
		return false
	end

	if player == character then
		return true
	end

	return player:IsDescendantOf(character)
end

local function ownedByLocal(items)
	if type(items) ~= "table" then
		return isLocalViewer(items)
	end

	for _, player in items do
		local v

		if typeof(player) == "Instance" then
			local localPlayer = Players.LocalPlayer

			if localPlayer == nil then
				v = false
			elseif player:IsA("Player") then
				v = player == localPlayer
			else
				local character = localPlayer.Character

				if character == nil then
					v = false
				else
					v = player == character or player:IsDescendantOf(character)
				end
			end
		else
			v = false
		end

		if v then
			return true
		end
	end

	return false
end

local Screen = {}

function Screen:Emit(p, callback)
	if self == nil or object[self] ~= nil then
		return
	end

	local owner

	if p ~= nil then
		owner = p.Owner
	end

	if owner == nil then
		warn((`Ouwmit: screen effect '{self:GetFullName()}' emitted with no Properties.Owner, so it pins to EVERY client that ran this effect`))
	else
		local v

		if type(owner) == "table" then
			local flag = true

			for _, player in owner do
				local v2

				if typeof(player) == "Instance" then
					local localPlayer = Players.LocalPlayer

					if localPlayer == nil then
						v2 = false
					elseif player:IsA("Player") then
						v2 = player == localPlayer
					else
						local character = localPlayer.Character

						if character == nil then
							v2 = false
						else
							v2 = player == character or player:IsDescendantOf(character)
						end
					end
				else
					v2 = false
				end

				if not v2 then
					continue
				end

				v = true
				flag = false
				break
			end

			if flag then
				v = false
			end
		elseif typeof(owner) == "Instance" then
			local localPlayer = Players.LocalPlayer

			if localPlayer == nil then
				v = false
			elseif owner:IsA("Player") then
				v = owner == localPlayer
			else
				local character = localPlayer.Character

				if character == nil then
					v = false
				elseif owner == character then
					v = true
				else
					v = owner:IsDescendantOf(character)
				end
			end
		else
			v = false
		end

		if not v then
			return
		end
	end

	local attribute = OuwmitUtility.GetAttribute(self, "PartScale", createVector(1, 1, 1))
	local attribute2 = OuwmitUtility.GetAttribute(self, "PartDistance", 1.5)
	local durationScale = OuwmitUtility.DurationScale(p)
	local attribute3 = OuwmitUtility.GetAttribute(self, "ScreenDuration", nil)
	local v

	if attribute3 == nil then
		v = OuwmitUtility.EstimateDuration(self) * durationScale
	else
		v = attribute3 * durationScale
	end

	local attribute4 = OuwmitUtility.GetAttribute(self, "OffsetPosition", createVector(0, 0, 0))
	local v2 = OuwmitUtility.GetAttribute(self, "OffsetRotation", createVector(0, 0, 0)) * OuwmitUtility.DEG_TO_RAD
	local cFrame = self.CFrame
	local size = self.Size
	local anchored = self.Anchored
	local canCollide = self.CanCollide
	local canQuery = self.CanQuery
	local canTouch = self.CanTouch
	self.Anchored = true
	self.CanCollide = false
	self.CanQuery = false
	self.CanTouch = false

	local function frame()
		local currentCamera = workspace.CurrentCamera

		if currentCamera == nil then
			return
		end

		local v3 = math.tan((math.rad(currentCamera.FieldOfView / 2))) * attribute2 * 2
		local v4 = currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y * v3
		local v5 = currentCamera.CFrame * CFrame.new(0, 0, -attribute2)
		self.Size = Vector3.new(v4, v3, size.Z) * attribute
		self.CFrame = v5 * CFrame.new(attribute4) * CFrame.fromOrientation(v2.x, v2.y, v2.z)
	end

	local total = 0
	local fn

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanup()
		Animator.Remove(fn)
		object[self] = nil
		self.Size = size
		self.CFrame = cFrame
		self.Anchored = anchored
		self.CanCollide = canCollide
		self.CanQuery = canQuery
		self.CanTouch = canTouch
	end

	fn = function(p2)
		if self:IsDescendantOf(game) and not (v <= total) then
			frame()
			total += p2
		else
			cleanup() -- equivalent call inferred; original call site unknown
		end
	end

	object[self] = cleanup
	frame()
	Animator.Add(fn)

	if callback ~= nil then
		for _, child in ipairs(self:GetChildren()) do
			callback(child, p)
		end
	end
end

function Screen.IsSpun(instance)
	local model = instance:FindFirstAncestorOfClass("Model")

	if model == nil then
		return false
	end

	return OuwmitUtility.GetAttribute(model, "SpinRotation", createVector(0, 0, 0)) ~= createVector(0, 0, 0) or OuwmitUtility.GetAttribute(
		model,
		"Scale_Start",
		1
	) ~= 1 or OuwmitUtility.GetAttribute(model, "Scale_End", 1) ~= 1 or OuwmitUtility.GetAttribute(
		model,
		"SyncPosition",
		false
	) == true
end

function Screen.Stop(p)
	local v = object[p]

	if v ~= nil then
		v()
	end
end

return Screen