local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local ErrorBoundary = require(script.Parent.ErrorBoundary)
local useErrorBoundary = require(script.Parent.useErrorBoundary)
local createElement = React.createElement
return function()
	describe("ErrorBoundary", function()
		local folder = nil
		local v = nil
		beforeEach(function()
			folder = Instance.new("Folder")
			v = nil
		end)

		local function render()
			local function fn()
				v = useErrorBoundary()
				return createElement("Frame", {
					key = "Child"
				})
			end

			local root = ReactRoblox.createRoot(folder);
			(function()
				root:render(createElement(ErrorBoundary, {
					fallback = createElement("Frame", {
						key = "Fallback"
					})
				}, {
					Content = createElement(fn)
				}))
			end)()
			task.wait()
		end

		it("should activate an error boundary", function()
			render()
			expect(folder:FindFirstChild("Child")).to.be.ok()
			assert(v)
			v.showBoundary("Error")
			task.wait()
			expect(folder:FindFirstChild("Fallback")).to.be.ok()
		end)
		it("should reset an active error boundary", function()
			render()
			assert(v)
			v.showBoundary("Error")
			task.wait()
			expect(folder:FindFirstChild("Fallback")).to.be.ok()
			assert(v)
			v.resetBoundary()
			task.wait()
			expect(folder:FindFirstChild("Child")).to.be.ok()
		end)
		it("should work within a fallback component", function()
			local resetBoundary = nil
			local showBoundary = nil

			local function FallbackComponent()
				resetBoundary = useErrorBoundary().resetBoundary
				return createElement("Frame", {
					key = "Fallback"
				})
			end

			local function fn()
				showBoundary = useErrorBoundary().showBoundary
				return createElement("Frame", {
					key = "Child"
				})
			end

			local root = ReactRoblox.createRoot(folder);
			(function()
				root:render(createElement(ErrorBoundary, {
					FallbackComponent = FallbackComponent
				}, {
					Child = createElement(fn)
				}))
			end)()
			task.wait()
			expect(folder:FindFirstChild("Child")).to.be.ok()
			assert(showBoundary)
			showBoundary("Error")
			task.wait()
			expect(folder:FindFirstChild("Fallback")).to.be.ok()
			assert(resetBoundary)
			resetBoundary()
			task.wait()
			expect(folder:FindFirstChild("Child")).to.be.ok()
		end)
	end)
end