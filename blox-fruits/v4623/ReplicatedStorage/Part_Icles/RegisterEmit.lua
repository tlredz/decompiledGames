local Events = require(script.Parent.Events)
return function(p)
	function p:_registerEmit(state, p2)
		if (self.MAX_ACTIVE_PARTICLES or 1000) <= #self.ActiveEmits + (self._lingerVisualCount or 0) then
			local v = state.IsAnimate and (state.Type == "Part" or state.Type == "Attachment" or state.Type == "Beam" or state.Type == "Model")

			if state.IsAnimate and state._sourceItem then
				self.ActiveAnimates[state._sourceItem] = nil
			end

			if not v and state.VisualPart and state.VisualPart.Parent then
				self:_releaseOrDestroy(state, state.VisualPart)
			end
		else
			state.EventChainCtx = p2 and p2.ChainCtx or state.EventChainCtx or Events.newChainCtx()
			local _playToken = p2 and p2._playToken

			if _playToken then
				state._playToken = _playToken

				if _playToken.TsOverride ~= nil and _playToken.TsUntil and os.clock() < _playToken.TsUntil then
					state._tsOverride = _playToken.TsOverride
					state._tsOverrideUntil = _playToken.TsUntil
				end
			end

			table.insert(self.ActiveEmits, state)

			if state.Events and state.Events.OnHit then
				state.LastHitCheckPos = Events.getWorldPosition(state)
				state.HitParams = Events.makeHitParams(state)
				state._hitFired = false
			end

			if state.Events and state.Events.OnEmit then
				local payload = Events.makePayload(self, state, "OnEmit", p2)
				Events.fire(self, state, "OnEmit", state.EventChainCtx, payload)
			end
		end
	end
end