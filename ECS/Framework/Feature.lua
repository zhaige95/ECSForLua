-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 系统集基类
-- Date - 2023-5-25
-- by - 良人
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
local Feature = class('Feature')

function Feature:ctor()
    self.__systems = {}

end

function Feature:Add(sys)
    table.insert(self.__systems, sys.new(self.__service))
end

function Feature:Execute(dt)
    for key, value in ipairs(self.__systems) do
        value:Execute(dt)
    end
end

function Feature:OnDispose()
    for key, value in ipairs(self.__systems) do
        value:OnDispose()
        self.__systems[key] = nil
    end
    self.__systems = {}
end

return Feature