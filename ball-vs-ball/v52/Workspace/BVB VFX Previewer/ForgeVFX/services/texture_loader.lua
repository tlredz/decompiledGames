local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local module = require("../obj/ObjectCache")
require("../types")
local module2 = require("../mod/utility")
local module3 = require("../mod/common/flipbook")
return {
	init = function(list)
		local decal = Instance.new("Decal")
		local part = Instance.new("Part")
		part.Name = "DO_NOT_REMOVE_ForgeTextureCache"
		part.Transparency = 1
		part.Size = createVector(0, 0, 0)
		part.Archivable = false
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Locked = true
		part.Parent = workspace.Terrain
		module2.protectParent(list, part)
		local v = module.new(decal, part, {
			size = 360,
			on_free = function(p)
				p.value.Texture = ""
			end
		})
		local v2 = {}

		local function createLoader(beam, fn, fn2)
			local v3 = {}
			local v4 = {}
			table.insert(v3, v4)

			local function refresh()
				module2.cleanupScope(v4)

				local function add(texture: string)
					if texture == "" then
						return
					end

					local get = v:get(texture)
					get.Texture = texture
					table.insert(v4, function()
						v:free(texture)
					end)
				end

				fn(add)
			end

			module2.cleanupScope(v4)

			local function add(texture: string)
				if texture == "" then
					return
				end

				local get = v:get(texture)
				get.Texture = texture
				table.insert(v4, function()
					v:free(texture)
				end)
			end

			fn(add)

			if module2.PLUGIN_CONTEXT and fn2 then
				for _, v5 in fn2((module2.reboundfn(1, refresh))) do
					table.insert(v3, v5)
				end
			end

			v2[beam] = v3
		end

		local function loadTextures(beam)
			if beam:IsDescendantOf(workspace.Terrain) then
				return
			end

			if module2.isMeshVFX(beam) then
				local start = beam:FindFirstChild("Start")

				if start and start:IsA("BasePart") then
					createLoader(beam, function(callback)
						local meshDecals, v3 = module2.getMeshDecals(beam, start)

						for _, texture in meshDecals do
							if typeof(texture) ~= "string" then
								texture = texture.Texture or texture
							end

							callback(texture)
						end

						for _, v4 in v3 do
							local texturePrefix = module3.getTexturePrefix(beam)

							for _, v5 in v4 do
								callback((`{texturePrefix}{v5}`))
							end
						end
					end, function(p)
						return { start.DescendantAdded:Connect(p), start.DescendantRemoving:Connect(p) }
					end)
				end
			elseif beam:IsA("Beam") then
				createLoader(beam, function(callback)
					callback(beam.Texture)
					local flipbookData = module3.getFlipbookData(beam)

					if flipbookData then
						local texturePrefix = module3.getTexturePrefix(beam)

						for _, v3 in flipbookData do
							callback((`{texturePrefix}{v3}`))
						end
					end
				end, function(onAttributeChanged)
					return {
						beam:GetPropertyChangedSignal("Texture"):Connect(onAttributeChanged),
						beam.AttributeChanged:Connect(onAttributeChanged)
					}
				end)
			else
				createLoader(beam, function(callback)
					-- equivalent calls inferred from this helper; original call sites unknown
					local function check(emitter)
						if emitter:IsA("ParticleEmitter") then
							callback(emitter.Texture)
						end
					end

					check(beam) -- equivalent call inferred; original call site unknown

					for _, descendant in beam:GetDescendants() do
						check(descendant) -- equivalent call inferred; original call site unknown
					end
				end, function(p)
					return { beam.DescendantAdded:Connect(p), beam.DescendantRemoving:Connect(p) }
				end)
			end
		end

		for _, v3 in CollectionService:GetTagged(module2.TEXTURE_LOAD_TAG) do
			loadTextures(v3)
		end

		CollectionService:GetInstanceAddedSignal(module2.TEXTURE_LOAD_TAG):Connect(loadTextures)
		CollectionService:GetInstanceRemovedSignal(module2.TEXTURE_LOAD_TAG):Connect(function(p)
			local v3 = v2[p]

			if v3 then
				module2.cleanupScope(v3)
				v2[p] = nil
			end
		end)
		table.insert(list, function()
			v:destroy()

			for _, v3 in v2 do
				module2.cleanupScope(v3)
			end
		end)
	end
}