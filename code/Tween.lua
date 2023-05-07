--[[

	tween.lua

	Tween functions

	Dustin Heyden
	16 Feb 2023



	Helper functions to create smooth tween movements	

]]

Tween = {}
Tween.__index = Tween

function Tween:IsFinished()
	return self.isFinished
end


function Tween:Value()
	return self.current
end



function Tween.Linear(timePassed, start, distance, duration)
	return distance * timePassed / duration + start
end

function Tween:FinishValue()
	return self.startValue + self.distance
end

function Tween:Update(elapsedTime)
	self.timePassed = self.timePassed + (elapsedTime or GetDeltaTime())
	self.current = self.tweenF(self.timePassed, self.startValue, self.distance, self.totalDuration)

    if self.timePassed > self.totalDuration then
	    self.current = self.startValue + self.distance
	    self.isFinished = true
    end
end


--
-- @start 			start value
-- @finish 			end value
-- @totalDuration 	time in which to perform tween
-- @tweenF			tween function, defaults to linear
function Tween:Create(start, finish, totalDuration, tweenF)
	local this =
	{
		tweenF = tweenF or Tween.Linear,
		distance = finish - start,
		startValue = start,
		current = start,
		totalDuration = totalDuration,
		timePassed = 0,
		isFinished = false
	}
	setmetatable(this, self)
	return this
end