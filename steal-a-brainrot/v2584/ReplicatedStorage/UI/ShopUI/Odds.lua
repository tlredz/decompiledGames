local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local vide = require(packages.vide)
local Animals = require(ReplicatedStorage.Shared.Animals)
local LuckyBlocks = require(ReplicatedStorage.Datas.LuckyBlocks)
local LuckyBlockFlags = require(ReplicatedStorage.Shared.Flags.LuckyBlockFlags)
local Reactive = require(script.Parent.Reactive)
require(script.Parent.State)
local effect = vide.effect

local function collectEntries(p: string)
	local result = {}
	local v2 = LuckyBlockFlags.OddsOverride:Get()[p]

	if v2 and next(v2) then
		for k, chance in v2 do
			table.insert(result, {
				Animal = k,
				Chance = chance
			})
		end
	else
		local luckyBlock = LuckyBlocks[p]

		if not luckyBlock then
			return result
		end

		for _, animal in luckyBlock.Animals do
			if (not animal.IsEnabled or animal.IsEnabled()) and animal.Chance then
				table.insert(result, {
					Animal = animal.Name,
					Chance = animal.Chance
				})
			end
		end
	end

	table.sort(result, function(a, b)
		return b.Chance < a.Chance
	end)
	return result
end

local function buildStrip(guiObject, p: string, mutation: string?)
	local template = guiObject:FindFirstChild("Template")

	if not (template and template:IsA("GuiObject")) then
		return
	end

	local v2 = collectEntries(p)

	if #v2 == 0 then
		return
	end

	local maid = Reactive.Trove()
	local xScalar = guiObject:GetAttribute("XScalar") or 1
	local v3 = template.Size.X.Scale * xScalar
	local v4 = math.ceil(1 / v3) + 1
	local v5 = math.ceil(v4 / #v2) * #v2
	local clones = table.create(v5)
	local total = 0

	for i = 1, v5 do
		local v6 = v2[(i - 1) % #v2 + 1]
		local clone = maid:Clone(template)
		clone.Name = tostring(i)
		clone.LayoutOrder = i
		clone.Chance.Text = `{v6.Chance}%`
		clone.Visible = true
		clone.Position = UDim2.fromScale(total, 0.5)
		clone.Parent = guiObject
		total += v3
		clones[i] = clone
		local v7 = Animals:AttachOnViewport(v6.Animal, clone, true, mutation)

		if v7 then
			maid:Add(v7)
		end
	end

	if #clones < v4 then
		return
	end

	local v6 = not (xScalar > 1) and 0.5 or xScalar * 0.5
	local v7 = v3 * #clones
	maid:Add(RunService.PreRender:Connect(function(dt: number)
		local v8 = v3 * dt * v6

		for _, v9 in clones do
			v9.Position -= UDim2.fromScale(v8, 0)

			if v9.Position.X.Scale <= -v3 then
				v9.Position += UDim2.fromScale(v7, 0)
			end
		end
	end))
end

return table.freeze({
	Mount = function(self, p: string, data)
		if not self:IsA("GuiObject") then
			return
		end

		local v2 = Reactive.FromSubscription(function(onChanged)
			return LuckyBlockFlags.OddsOverride.Changed:Connect(onChanged)
		end, function()
			return os.clock()
		end)
		effect(function()
			local opened = data.Opened()
			local mutation = data.Mutation()
			data.UpdatesRevision()
			v2()
			self.Visible = opened

			if not opened then
				return
			end

			buildStrip(self, p, mutation)
		end)
	end
})