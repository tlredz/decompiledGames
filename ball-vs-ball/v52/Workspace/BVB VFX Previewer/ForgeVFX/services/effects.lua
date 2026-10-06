require("../types")
local module = require("../mod/logger")
local module2 = require("../mod/utility")
local module3 = require("../emitters")
local module4 = require("../pkg/Promise")
local joined = table.concat({
	"Beam",
	"Trail",
	"Sound",
	"ParticleEmitter",
	`.{module2.BEZIER_TAG}`,
	`.{module2.LIGHTNING_TAG}`,
	"Model",
	"RayValue",
	"BasePart[$Enabled=true]",
	"#Rings > Part",
	"#Lines > Part",
	"#Debris > Part"
}, ",")
local Effects = {}
local v = nil

local function fn() end

local v2 = {
	Finished = module4.resolve(),
	Clear = fn
}

function Effects.init(p)
	v = p
end

function Effects.deinit()
	v = nil
end

local function emitWithContext(depth: number, context, ...)
	if not (v and v.setup) then
		module.error("effects service not initialized")
		return v2
	end

	local v3 = {}
	local v4 = {}

	local function queryAndEmitDescendants(part, p3: number)
		local descendants = part:QueryDescendants(joined)
		local count = #descendants

		if count == 0 then
			return {}
		end

		local result = table.create(count)
		local v5 = {
			[part] = false
		}
		local v6 = {
			[part] = p3
		}

		for _, descendant in descendants do
			local parent = descendant.Parent
			local parents = {}

			while v6[parent] == nil do
				table.insert(parents, parent)
				parent = parent.Parent
			end

			local v7 = v5[parent]
			local v8 = v6[parent]

			for i = #parents, 1, -1 do
				local v9 = parents[i]
				v8 += 1
				v6[v9] = v8
				v7 = v7 or module2.shouldSkipNested(v9) or v9:HasTag(module2.EMIT_EXCLUDE_TAG)
				v5[v9] = v7
			end

			if v7 then
				continue
			end

			local v9 = descendant
			table.insert(result, module2.createEmitPromise(Effects, descendant, v6[descendant.Parent], function(p4)
				module3.dispatch(v9, p4, v3, v4, v.caches.shared_part, 1)
			end, context))
		end

		return result
	end

	local v5 = {}

	for _, part in { ... } do
		if part:IsA("BasePart") and part:GetAttribute("Enabled") and not module2.findFirstClassWithTag(
			part,
			"Attachment",
			module2.SHOCKWAVE_TAG
		) then
			if not module2.lock(part) then
				local model = part:FindFirstAncestorOfClass("Model")

				if not model or module2.isSpinModelStatic(model) then
					local thread = coroutine.running()
					local v6 = {
						depth = depth,
						effects = Effects,
						_context = context
					}

					if module3.screen(part, v6) then
						local v7 = queryAndEmitDescendants(part, depth + 1)

						if #v7 > 0 then
							local v8 = part
							local v9 = thread
							local v10 = v6
							table.insert(v5, module4.all(v7):finally(function()
								module2.unlock(v8, v9)
								module2.cleanupScope(v10)
							end))
						else
							module2.unlock(part, thread)
							module2.cleanupScope(v6)
						end
					end
				end
			end
		else
			local v6 = part
			table.insert(v5, module2.createEmitPromise(Effects, part, depth, function(p3)
				module3.dispatch(v6, p3, v3, v4, v.caches.shared_part, 1)
			end, context))

			if not module2.shouldSkipNested(part) then
				local v7 = queryAndEmitDescendants(part, depth + 1)

				for _, v8 in v7 do
					table.insert(v5, v8)
				end
			end
		end
	end

	local v6 = {
		Finished = module4.all(v5)
	}
	v6.Clear = context and function()
		for _, _promis in context._promises do
			_promis:cancel()
		end

		v6.Finished:cancel()
	end or fn
	return v6
end

function Effects.emit(p: number, ...)
	return emitWithContext(p, {
		_promises = {}
	}, ...)
end

function Effects.prepareEmitFolder(instance, childName: string, folders)
	local folder = instance:FindFirstChild(childName)

	if folder and folder:IsA("Folder") then
		folder.Parent = nil
		table.insert(folders, folder)
		return folder
	else
		return nil
	end
end

function Effects.prepareEmitOnFinish(p, p2)
	return Effects.prepareEmitFolder(p, "EmitOnFinish", p2)
end

function Effects.emitNested(instance, p: number, p2)
	if not (v and v.setup) then
		return v2
	end

	local children = instance:GetChildren()

	if #children == 0 then
		return v2
	end

	local v3

	if p2 then
		v3 = p2._context
	end

	return emitWithContext(p, v3, table.unpack(children))
end

function Effects.emitFromFolder(instance, parent, p: number, p2)
	if not instance then
		return v2
	end

	local children = instance:GetChildren()

	if #children == 0 then
		return v2
	end

	for _, v3 in children do
		v3.Parent = parent
	end

	local v3

	if p2 then
		v3 = p2._context
	end

	return emitWithContext(p, v3, table.unpack(children))
end

function Effects.emitOnFinish(p, p2, p3: number, p4)
	return Effects.emitFromFolder(p, p2, p3, p4)
end

return Effects