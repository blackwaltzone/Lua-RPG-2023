--[[

	FadeState.lua

	Render a black rectangle covering screen
	Use tween to make rectangle more and more transparent
	When fully transparent, state is popped off stack


	Dustin Heyden

	06 May, 2023

]]

FadeState = {}
FadeState.__index = FadeState

function FadeState:Create(stack, params)
	params = params or {}

	local this =
	{
		-- so it can pop itself
		Stack = stack,
		AlphaStart = params.start or 1,
		AlphaFinish = params.finish or 0,
		-- time in seconds
		Duration = params.time or 1,
	}

	this.Color = params.color or Vector.Create(0,0,0,this.AlphaStart)
	this.Tween = Tween:Create(this.AlphaStart,
							this.AlphaFinish,
							this.Duration)

	setmetatable(this, self)

	return this
end


function FadeState:Enter() end

function FadeState:Exit() end

function FadeState:HandleInput() end

function FadeState:Update(dt)
	self.Tween:Update(dt)

	local alpha = self.Tween:Value()
	self.color:SetW(alpha)

	if self.Tween:IsFinished() then
		self.Stack:Pop()
	end

	return true
end


function FadeState:Render(renderer)
	renderer:DrawRect2d(
		-System.ScreenWidth() / 2,
		System.ScreenHeight() / 2,
		System.ScreenWidth() / 2,
		-System.ScreenHeight() / 2,
		self.Color)
end