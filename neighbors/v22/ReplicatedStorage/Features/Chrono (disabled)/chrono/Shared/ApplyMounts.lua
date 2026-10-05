local createVector = vector.create
local Entity = require(script.Parent.Entity)
local Events = require(script.Parent.Events)
local Holder = require(script.Parent.Holder)
require(script.Parent.Types)
local count = 0
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function SetCFrame(p, cFrame: CFrame)
	local _GetRootPart = Entity._GetRootPart(p)

	if _GetRootPart then
		_GetRootPart.CFrame = cFrame

		if p.isContextOwner then
			_GetRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			_GetRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		end
	end
end

local function ResolveWorldCFrame(k)
	local v6 = count

	if v2[k] == v6 then
		return v3[k]
	end

	local _ = CFrame.identity
	local v7 = k
	local count2 = 0
	local cFrame

	while true do
		if v2[v7] == v6 then
			cFrame = v3[v7]
			break
		end

		if v[v7] == v6 then
			cFrame = Entity.GetAt(v7, Entity.GetTargetRenderTime(v7)) or v7.latestCFrame or CFrame.identity
			v2[v7] = v6
			v3[v7] = cFrame
			local _GetRootPart = Entity._GetRootPart(v7)

			if not _GetRootPart then
				break
			end

			_GetRootPart.CFrame = cFrame

			if not v7.isContextOwner then
				break
			end

			_GetRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			_GetRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			break
		else
			v[v7] = v6
			local mountParentId = v7.mountParentId

			if mountParentId then
				local entity = Holder.GetEntityFromId(mountParentId)

				if entity and not entity.destroyed then
					count2 += 1
					v4[count2] = v7
					v7 = entity
				else
					cFrame = Entity.GetAt(v7, Entity.GetTargetRenderTime(v7)) or v7.latestCFrame or CFrame.identity
					v2[v7] = v6
					v3[v7] = cFrame
					local _GetRootPart = Entity._GetRootPart(v7)

					if not _GetRootPart then
						break
					end

					_GetRootPart.CFrame = cFrame

					if not v7.isContextOwner then
						break
					end

					_GetRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
					_GetRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
					break
				end
			else
				if v7.isContextOwner then
					local primaryPart = Entity.GetPrimaryPart(v7)

					if primaryPart then
						cFrame = primaryPart.CFrame
					else
						cFrame = v7.latestCFrame or CFrame.identity
					end
				else
					cFrame = Entity.GetAt(v7, Entity.GetTargetRenderTime(v7)) or v7.latestCFrame or CFrame.identity
				end

				v2[v7] = v6
				v3[v7] = cFrame
				break
			end
		end
	end

	local v8 = cFrame or CFrame.identity

	for i = count2, 1, -1 do
		local v9 = v4[i]
		v8 *= v9.mountOffset or CFrame.identity
		v2[v9] = v6
		v3[v9] = v8
		SetCFrame(v9, v8) -- equivalent call inferred; original call site unknown
		v4[i] = nil
	end

	if v2[k] == v6 then
		return v3[k]
	end

	v2[k] = v6
	v3[k] = v8
	SetCFrame(k, v8) -- equivalent call inferred; original call site unknown
	return v3[k]
end

Events.EntityAdded:Connect(function(p)
	if p.mountParentId then
		v5[p] = true
	end
end, true)
Events.EntityMountChanged:Connect(function(p, p2: number?)
	if p2 then
		v5[p] = true
	else
		v5[p] = nil
	end
end, true)
Events.EntityRemoved:Connect(function(p)
	v2[p] = nil
	v3[p] = nil
	v5[p] = nil
end, true)

local function ApplyMounts()
	debug.profilebegin("ApplyMounts")

	for k in v5 do
		if k.destroyed or v2[k] == count then
			continue
		end

		ResolveWorldCFrame(k)
	end

	count += 1
	debug.profileend()
end

return ApplyMounts