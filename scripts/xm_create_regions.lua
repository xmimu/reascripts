-- @description Create Regions
-- @author lgx
-- @version 1.0
-- @about

local function compareSegments(seg1, seg2)
    return seg1[1] < seg2[1]
end

local function mergeSegments(segments)
    -- Sort table
    table.sort(segments, compareSegments)

    -- Init result table
    local mergedSegments = {}
    
    -- Insert first segment
    table.insert(mergedSegments, segments[1])
    
    -- Check segments
    for i = 2, #segments do
        local currentSegment = segments[i]
        local lastMergedSegment = mergedSegments[#mergedSegments]
        
        -- Merge
        if currentSegment[1] <= lastMergedSegment[2] then
            lastMergedSegment[2] = math.max(lastMergedSegment[2], currentSegment[2])
        else
            table.insert(mergedSegments, currentSegment)
        end
    end
    
    return mergedSegments
end

local function getItemData()
    local num = reaper.CountSelectedMediaItems(0)
    if num == 0 then return end
    local segments = {}
    for i = 0, num - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        local take = reaper.GetActiveTake(item)
        if take then
            local name = reaper.GetTakeName(take)
            local start_p = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            local end_p = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") + start_p
            table.insert(segments, {start_p, end_p})
        end
    end
    return segments
end

local function createRegions(segments)
  for _, segment in ipairs(segments) do
      reaper.AddProjectMarker(0, true, segment[1], segment[2], "", -1)
  end
end

function main()

    local segments = getItemData()
    
    if not segments then return end
    
    local mergedSegments = mergeSegments(segments)
    
    createRegions(mergedSegments)

end

main()

