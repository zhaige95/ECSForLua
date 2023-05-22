require("Core.functions")

require("ECS.Context")


require("Generated.GeneratedContext")

-- print(Context.mEntityUID)

local e = Context:CreateEntity()
e:AddTest("new  test", {43,5,62,523})

local m = Context:Matcher():AllOf(11,1,2,45,3)
