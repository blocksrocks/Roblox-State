local Signal = _G.require("Signal")

local State = {}
State.__index = State

function State.new()
	local self = setmetatable({}, State)

	self._connections = {}
	self.forward = Signal.new()

	self.forward:Connect(function()
		self:Destroy()
	end)

	return self
end

function State:Depend(dependencies)
	for index = 1, #dependencies do
		local trigger = dependencies[index]

		if typeof(trigger) == "RBXScriptSignal" then
			table.insert(self._connections, trigger:Connect(function(...)
				self.forward:Fire(...)
			end))
		elseif trigger then
			self.forward:Fire()
			return
		end
	end
end

function State:Destroy()
	for index = 1, #self._connections do
		self._connections[index]:Disconnect()
		self._connections[index] = nil
	end

	self._connections = nil

	self.forward:Destroy()
	self.forward = nil

	setmetatable(self, nil)
end

return State