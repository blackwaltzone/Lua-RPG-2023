--[[

	WaitState.lua

	Wait State


	waiting state for character controller state machine


	Dustin Heyden
	16 Feb 2023

]]


WaitState = { Name = "wait" }
WaitState.__index = WaitState

function WaitState:Create(character, map)
	local this =
	{
		Character = character,
		Map = map,
		Entity = character.Entity,
		Controller = character.Controller,

		-- how long character is in waitstate before resetting to
		-- default frame
		FrameResetSpeed = 0.05,
		FrameCount = 0
	}

	setmetatable(this, self)

	return this
end


function WaitState:Enter(data)
	-- reset to default frame
	self.FrameCount = 0
end


function WaitState:Render(renderer) end

function WaitState:Exit() end


function WaitState:Update(dt)
	-- If we're int he wait state for a few frames, reset the frame to
	-- the starting frame
	if self.FrameCount ~= -1 then
		self.FrameCount = self.FrameCount + dt
		if self.FrameCount >= self.FrameResetSpeed then
			self.FrameCount = -1   -- stops the check
			self.Entity:SetFrame(self.Entity.StartFrame)
			self.Character.Facing = "down"
		end
	end

	if Keyboard.Held(KEY_LEFT) then
		self.Controller:Change("move", { x = -1, y = 0 })
		--self.Character.Facing = "right"
	elseif Keyboard.Held(KEY_RIGHT) then
		self.Controller:Change("move", { x = 1, y = 0 })
		--self.Character.Facing = "left"
	elseif Keyboard.Held(KEY_UP) then
		self.Controller:Change("move", { x = 0, y = -1 })
		--self.Character.Facing = "up"
	elseif Keyboard.Held(KEY_DOWN) then
		self.Controller:Change("move", { x = 0, y = 1 })
		--self.Character.Facing = "down"
	end
end
