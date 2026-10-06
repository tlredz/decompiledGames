local function unavailableMessage(p)
	local v = {}

	for i = 1, math.min(3, #(p.unavailable or {})) do
		v[i] = p.unavailable[i]
	end

	local v2 = #(p.unavailable or {}) - #v
	return "These items cannot be bought here: " .. table.concat(v, ", ") .. (v2 > 0 and " and " .. v2 .. " more" or "") .. ". Remove or replace them before saving."
end

local OutfitSaveFlow = {}

function OutfitSaveFlow.BuildPlan(list)
	local result = {
		missing = {},
		unavailable = {},
		lineItems = {},
		buyable = 0,
		prompted = {}
	}

	for _, v in ipairs(list) do
		if not v.known then
			return {
				error = "Some items could not be checked. Please try saving again."
			}
		end

		if v.owned then
			continue
		end

		table.insert(result.missing, v.id)

		if v.available and not v.redemptionOnly then
			result.buyable += 1

			if #result.lineItems < 20 then
				table.insert(result.lineItems, {
					Type = Enum.MarketplaceProductType.AvatarAsset,
					Id = string.format("%.0f", v.id)
				})
			end
		else
			table.insert(result.unavailable, v.name)
		end
	end

	result.ready = #result.missing == 0
	return result
end

function OutfitSaveFlow.new(data)
	return {
		phase = "idle",
		generation = 0,
		Stop = function(self, p2)
			self.generation += 1
			self.phase = "idle"
			self.kind = nil
			self.batch = nil
			self.early = nil
			data.Cleanup()
			data.Busy(false)

			if p2 then
				data.Status(p2)
			end
		end,
		Cancel = function(self, p)
			if self.phase == "saving" then
				return
			end

			if self.phase ~= "idle" then
				self:Stop(p)
			end
		end,
		SaveFinished = function(self, p, p2)
			if self.phase == "saving" and self.kind == p then
				self:Stop(p2)
			end
		end,
		Check = function(self, p2, p3)
			local success, result = pcall(data.Check, p2)

			if self.generation ~= p3 then
				return nil
			end

			if success and type(result) == "table" then
				return result
			end

			return {
				error = "Could not check your outfit. Please try again."
			}
		end,
		Unavailable = function(self, p)
			local v = unavailableMessage(p)

			if self.kind == "Purchase" then
				v = v:gsub("%. Remove or replace them before saving%.$", ".")
			end

			self:Stop(v)
		end,
		OpenSave = function(self, p)
			if self.generation ~= p then
				return
			end

			if self.kind == "Purchase" then
				self:Stop("You own all the items in this outfit.")
				return
			end

			self.phase = "saving"
			data.Status("Review and confirm in Roblox's save prompt.")
			local success, result = pcall(data.Save, self.kind)

			if not success and self.generation == p then
				self:Stop("Roblox couldn't open the save prompt. Please try again in the published game.")

				if data.Warn then
					data.Warn(result)
				end
			end
		end,
		Request = function(self, p)
			self.phase = "checking"
			self.expectPurchase = true
			self.early = nil
			data.Status(self.kind == "Purchase" and "Checking outfit ownership…" or "Checking ownership before saving…")
			local v = self:Check(true, p)

			if not v then
				return
			end

			self.expectPurchase = false

			if v.error then
				self:Stop(v.error)
				return
			end

			if v.ready then
				self:OpenSave(p)
				return
			end

			if #(v.prompted or {}) == 0 then
				self:Unavailable(v)
				return
			end

			self.batch = v.prompted
			self.phase = "purchase"
			data.Status(self.kind == "Purchase" and "Review the missing items in Roblox's purchase prompt." or "Review the missing items in Roblox's purchase prompt. Saving continues after you own them.")

			if self.early ~= nil then
				local early = self.early
				self.early = nil
				self:PurchaseFinished(early)
			end
		end,
		PurchaseFinished = function(self, early)
			if self.phase == "checking" and self.expectPurchase then
				self.early = early
				return
			end

			if self.phase ~= "purchase" then
				return
			end

			if not early then
				self:Stop(self.kind == "Purchase" and "Purchase canceled or unsuccessful." or "Purchase canceled or unsuccessful. Nothing was saved.")
				return
			end

			local generation = self.generation
			local batch = self.batch
			self.phase = "checking"
			self.expectPurchase = false
			data.Status("Confirming your purchases…")
			local v = nil

			for i = 1, 3 do
				data.Wait(i)

				if self.generation ~= generation then
					return
				end

				v = self:Check(false, generation)

				if not v then
					return
				end

				if v.error then
					continue
				end

				if v.ready then
					self:OpenSave(generation)
					return
				end

				local v2 = {}

				for _, v3 in ipairs(v.missing or {}) do
					v2[v3] = true
				end

				local flag = true

				for _, v4 in ipairs(batch) do
					if not v2[v4] then
						continue
					end

					flag = false
					break
				end

				if not flag then
					continue
				end

				if (v.buyable or 0) > 0 then
					self:Request(generation)
				else
					self:Unavailable(v)
				end

				return
			end

			self:Stop(v and v.error or self.kind == "Purchase" and "Some items are still not owned. Try Purchase outfit again when you are ready." or "Some items are still not owned. Nothing was saved. Try saving again when you are ready.")
		end,
		Start = function(self, kind)
			if self.phase ~= "idle" or kind ~= "Avatar" and kind ~= "Outfit" and kind ~= "Purchase" then
				return false
			end

			self.generation += 1
			local generation = self.generation
			self.kind = kind
			self.phase = "checking"
			data.Busy(true)
			local success, result, v = pcall(data.Capture)

			if self.generation ~= generation then
				return false
			end

			if success and result then
				self:Request(generation)
				return true
			end

			self:Stop(v or "Wait for your character to spawn, then try again.")
			return false
		end
	}
end

return OutfitSaveFlow