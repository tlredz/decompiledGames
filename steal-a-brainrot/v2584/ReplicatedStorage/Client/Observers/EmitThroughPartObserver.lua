local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Observers = require(ReplicatedStorage.Packages.Observers)
local part = script.Part
local v = {}

local function start()
	return Observers.observeTag("EmitThroughPart", function(p)
		if not FFlags:GetInstant("Optimisation.EmitThroughPart", true) then
			return
		end

		local parent = p.Parent

		if not parent:IsA("Attachment") then
			return
		end

		local clone = v[parent]

		if not clone then
			clone = part:Clone()
			clone.RigidConstraint.Attachment0 = parent
			clone.Parent = parent
			local __derp_a1 = clone.__derp_a1
			__derp_a1.ChildRemoved:Connect(function(_)
				if __derp_a1:FindFirstChildOfClass("ParticleEmitter") == nil then
					clone:Destroy()
					v[parent] = nil
				end
			end)
			v[parent] = clone
		end

		p.Parent = clone.__derp_a1
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace })
end

local v2 = nil

local function toggle()
	if FFlags:GetInstant("Optimisation.EmitThroughPart", true) then
		if not v2 then
			v2 = Observers.observeTag("EmitThroughPart", function(p)
				if not FFlags:GetInstant("Optimisation.EmitThroughPart", true) then
					return
				end

				local parent = p.Parent

				if not parent:IsA("Attachment") then
					return
				end

				local clone = v[parent]

				if not clone then
					clone = part:Clone()
					clone.RigidConstraint.Attachment0 = parent
					clone.Parent = parent
					local __derp_a1 = clone.__derp_a1
					__derp_a1.ChildRemoved:Connect(function(_)
						if __derp_a1:FindFirstChildOfClass("ParticleEmitter") == nil then
							clone:Destroy()
							v[parent] = nil
						end
					end)
					v[parent] = clone
				end

				p.Parent = clone.__derp_a1
				return function()
					pcall(function()
						p.Parent = parent
					end)
				end
			end, { workspace })
		end
	elseif v2 then
		v2()
		v2 = nil
	end
end

if FFlags:GetInstant("Optimisation.EmitThroughPart", true) then
	if not v2 then
		v2 = Observers.observeTag("EmitThroughPart", function(p)
			if not FFlags:GetInstant("Optimisation.EmitThroughPart", true) then
				return
			end

			local parent = p.Parent

			if not parent:IsA("Attachment") then
				return
			end

			local clone = v[parent]

			if not clone then
				clone = part:Clone()
				clone.RigidConstraint.Attachment0 = parent
				clone.Parent = parent
				local __derp_a1 = clone.__derp_a1
				__derp_a1.ChildRemoved:Connect(function(_)
					if __derp_a1:FindFirstChildOfClass("ParticleEmitter") == nil then
						clone:Destroy()
						v[parent] = nil
					end
				end)
				v[parent] = clone
			end

			p.Parent = clone.__derp_a1
			return function()
				pcall(function()
					p.Parent = parent
				end)
			end
		end, { workspace })
	end
elseif v2 then
	v2()
	v2 = nil
end

FFlags:OnChange("Optimisation.EmitThroughPart", toggle)