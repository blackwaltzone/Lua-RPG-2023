--[[

	Icons.lua

	Handles inventory icons


	Dustin Heyden

	08 May, 2023

]]

Icons = {}
Icons.__index = Icons

function Icons:Create(texture)

	local this =
	{
		Texture = texture,
		UVs = {},
		Sprites = {},
		IconDefs =
		{
			useable = 1,
			accessory = 2,
			weapon = 3,
			armor = 4,
			uparrow = 5,
			downarrow = 6
		}
	}

	this.UVs = GenerateUVs(18, 18, this.Texture)

	for k, v in ipairs(this.IconDefs) do
		local sprite = Sprite.Create()
		sprite:SetTexture(this.Texture)
		sprite:SetUVs(unpack(this.UVs[v]))
		this.Sprites[k] = sprite
	end

	setmetatable(this, self)

	return this
end


function Icons:Get(id)
	return self.Sprites[id]
end