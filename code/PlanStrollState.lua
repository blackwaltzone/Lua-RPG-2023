--[[

	PlanStrollState.lua

	State that makes NPC wander around map
	Waits a random number of seconds, picks a random direction to move,
		chnage to moveState.


	Dustin Heyden

	06 April, 2023

]]


PlanStrollState = { Name = "plan_stroll" }
PlanStrollState.__index = PlanStrollState

function PlanStrollState:Create(character, map)
	local this =
	{
		Character = character,
		Map = map,
		Entity = character.Entity,
		Controller = character.Controller,

		FrameResetSpeed = 0.05,
		FrameCount = 0,

		CountDown = math.random(0, 3)
	}

	setmetatable(this, self)
	return this
end


function PlanStrollState:Enter()
	self.FrameCount = 0
	self.CountDown = math.random(0, 3)
end


function PlanStrollState:Exit() end


function PlanStrollState:Update(dt)

	self.CountDown = self.CountDown - dt

	if self.CountDown <= 0 then
		
		-- Choose a random direction and try to move that way
		local choice = math.random(4)

		if choice == 1 then
			self.Controller:Change("move", {x = -1, y = 0})
		elseif choice == 2 then
			self.Controller:Change("move", {x = 1, y = 0})
		elseif choice == 3 then
			self.Controller:Change("move", {x = 0, y = -1})
		elseif choice == 4 then
			self.Controller:Change("move", {x = 0, y = 1})
		end
	end

	-- if we're in the stroll state for a few frames, reset the
	-- frame to the starting frame
	if self.FrameCount ~= -1 then
		
		self.FrameCount = self.FrameCount + dt

		if self.FrameCount >= self.FrameResetSpeed then
			self.FrameCount = -1
			self.Entity:SetFrame(self.Entity.StartFrame)
			self.Character.Facing = "down"
		end
	end

end


function PlanStrollState:Render(renderer) end