--[[

	Animation.lua

	Animation handler


	Dustin Heyden
	24 Feb 2023

]]

Animation = {}
Animation.__index = Animation

function Animation:Create(frames, loop, spf)
	if loop == nil then
		loop = true
	end

	local this =
	{
		Frames = frames or {1},
		Index = 1,
		SPF = spf or 0.12,
		Time = 0,
		Loop = loop or true,
	}

	setmetatable(this, self)

	return this
end


function Animation:Update(dt)
	self.Time = self.Time + dt

	if self.Time >= self.SPF then
		
		self.Index = self.Index + 1
		self.Time = 0

		if self.Index > #self.Frames then

			if self.Loop then
				self.Index = 1
			else
				self.Index = #self.Frames
			end
		end
	end
end


function Animation:SetFrames(frames)
	self.Frames = frames
	self.Index = math.min(self.Index, #self.Frames)
end


function Animation:Frame()
	return self.Frames[self.Index]
end


function Animation:IsFinished()
	return self.Loop == false and self.Index == #self.Frames
end
