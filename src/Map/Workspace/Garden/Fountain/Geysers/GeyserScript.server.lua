local SmallCenter = script.Parent.SmallCenter:GetChildren()
local Big = script.Parent.Big:GetChildren()
local Small = script.Parent.Small:GetChildren()

while true do
	for i,parts in ipairs(SmallCenter) do
		parts.liq.Enabled = true
	end	
	wait(5)
	for i,parts in ipairs(Big) do
		parts.liq.Enabled = true
	end
	wait(2)
	for	i,parts in ipairs(Small) do
		parts.liq.Enabled = true
	end
	wait(5)
	for i,parts in ipairs(SmallCenter) do
		parts.liq.Enabled = false
	end	
	for i,parts in ipairs(Big) do
		parts.liq.Enabled = false
	end
	for	i,parts in ipairs(Small) do
		parts.liq.Enabled = false
	end
end