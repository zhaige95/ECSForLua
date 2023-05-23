-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 过滤组
-- Date - 2023-5-22
-- by - 良人
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

local Group = class("Group")

function Group:ctor(id, matcher)

    self:Reset()

    self.mAdded = matcher.mAdded
    self.mRemoved = matcher.mRemoved

    for key, value in pairs(matcher.mAllOfContent) do
        self.mAllOfIndexer[value] = true
        table.insert(self.mAllOfContent, value)
    end
    for key, value in pairs(matcher.mAllOfContent) do
        self.mNoneOfIndexer[value] = true
        table.insert(self.mNoneOfContent, value)
    end
    self.mID = id
end


function Group:OnDispose()

end


function Group:Reset()

    self.mAllOfContent = {}
    self.mNoneOfContent = {}

    self.mAllOfIndexer = {}
    self.mNoneOfIndexer = {}

    self.mAdded = false
    self.mRemoved = false

    self.mEntityIndexer = {}
end

function Group:OnAddComponent(e, comp)
    -- if  then

    -- end
end

function Group:Match(matcher)
    if #matcher.mAllOfContent ~= #self.mAllOfContent or #matcher.mNoneOfContent ~= #self.mNoneOfContent then
        return false
    end
    for _, value in pairs(matcher.mAllOfContent) do
        if not self.mAllOfIndexer[value] then
            return false
        end
    end
    for _, value in pairs(matcher.mNoneOfContent) do
        if not self.mNoneOfIndexer[value] then
            return false
        end
    end
    return true
end

return Group