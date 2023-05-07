--[[

	MoveState.lua

	Move State


	Move state for character controller state machien


	Dustin Heyden
	19 Feb 2023

]]--


MoveState = { Name = "move" }
MoveState.__index = MoveState

function MoveState:Create(character, map)
	local this =
	{
		Character = character,
		Map = map,
		TileWidth = map.TileWidth,
		Entity = character.Entity,
		Controller = character.Controller,
		MoveX = 0,
		MoveY = 0,
		Tween = Tween:Create(0, 0, 1),
		MoveSpeed = 0.3,
	}
	this.Anim = Animation:Create({this.Entity.StartFrame})

	setmetatable(this, self)

	return this
end


function MoveState:Enter(data)
	local frames = nil
	
	if data.x == -1 then
		frames = self.Character.Anims.left
		self.Character.Facing = "left"
	elseif data.x == 1 then
		frames = self.Character.Anims.right
		self.Character.Facing = "right"
	elseif data.y == -1 then
		frames = self.Character.Anims.up
		self.Character.Facing = "up"
	elseif data.y == 1 then
		frames = self.Character.Anims.down
		self.Character.Facing = "down"
	end

	self.Anim:SetFrames(frames)

	self.MoveX = data.x
	self.MoveY = data.y

	local pixelPos = self.Entity.Sprite:GetPosition()
	self.PixelX = pixelPos:X()
	self.PixelY = pixelPos:Y()

	self.Tween = Tween:Create(0, self.TileWidth, self.MoveSpeed)

	local targetX = self.Entity.TileX + data.x
	local targetY = self.Entity.TileY + data.y
	
	-- check to see if tile is blocked
	if self.Map:IsBlocked(1, targetX, targetY) then
		
		-- blocked, so don't move
		self.MoveX = 0
		self.MoveY = 0

		-- set player facing direction of attempted move
		self.Entity:SetFrame(self.Anim:Frame())
		self.Controller:Change(self.Character.DefaultState)

		return
	end

	if self.MoveX ~= 0 or self.MoveY ~= 0 then
		local trigger = self.Map:GetTrigger(self.Entity.Layer,
											self.Entity.TileX,
											self.Entity.TileY)
		if trigger then
			trigger:OnExit(self.Entity)
		end
	end

	self.Entity:SetTilePos(self.Entity.TileX + self.MoveX,
						   self.Entity.TileY + self.MoveY,
						   self.Entity.Layer,
						   self.Map)
	self.Entity.Sprite:SetPosition(pixelPos)
end


function MoveState:Exit()

	local trigger = self.Map:GetTrigger(self.Entity.Layer,
									self.Entity.TileX,
									self.Entity.TileY)

	if trigger then
		trigger:OnEnter(self.Entity)
	end
end


function MoveState:Render(renderer) end


function MoveState:Update(dt)

	self.Anim:Update(dt)
	self.Entity:SetFrame(self.Anim:Frame())

	self.Tween:Update(dt)

	local value = self.Tween:Value()
	local x = self.PixelX + (value * self.MoveX)
	local y = self.PixelY - (value * self.MoveY)
	self.Entity.X = math.floor(x)
	self.Entity.Y = math.floor(y)
	self.Entity.Sprite:SetPosition(self.Entity.X, self.Entity.Y)

	if self.Tween:IsFinished() then
		self.Controller:Change(self.Character.DefaultState)
	end
end
