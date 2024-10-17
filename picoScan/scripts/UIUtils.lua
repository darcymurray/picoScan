UiUtils = {}

--[[
  Wrapper to both add image to viewer and present

  Params:
  viewerHandle:View     Handle to the UI viewer object
  image:Image           The image to show

  Returns:
  none

  Author: Adrian Forbes
]]
function UiUtils.showImage(viewerHandle, image)
  if image ~= nil then
    viewerHandle:addImage(image)
    viewerHandle:present('LIVE')
  end
end

--[[
  Wrapper to both add pixel region to viewer and present

  Params:
  viewerHandle:View                 Handle to the UI viewer object
  region:Image.PixelRegion          The pixel region to show
  deco:View.PixelRegionDecoration   The decoration to apply to the pixel region

  Returns:
  none

  Author: Adrian Forbes
]]
function UiUtils.showRegion(viewerHandle, region, deco)
  if region ~= nil then
    viewerHandle:addPixelRegion(region, deco)
    viewerHandle:present('LIVE')
  end
end

--[[
  Converts a 2-dimensional table to a JSON string suitable for the AppSpace DynamicTable
  UI element. The members of the input table must be of type string or number; if any are
  not, their corresponding member in the JSON string will be a blank string. The first row
  of the input table must be the column names of the DynamicTable.

  The string outputted by this function can be directly passed to the 'data' event of an
  AppSpace DynamicTable. The DynamicTable data event expects a JSON string in the following format:
  [
    {"ColumnName1":Value11, "ColumnName2":Value12, ..., "ColumnNameN":Value1N},
    {"ColumnName1":Value21, "ColumnName2":Value22, ..., "ColumnNameN":Value2N},
    {"ColumnName1":Value31, "ColumnName2":Value32, ..., "ColumnNameN":Value3N},
    ...
    {"ColumnName1":ValueM1, "ColumnName2":ValueM2, ..., "ColumnNameN":ValueMN},
  ]

  Note that the column names must exactly match the names of the columns as defined in the 'id'
  field of each DynamicTableColumn element.

  Params:
    tbl:table                        The table to be converted

  Returns:
    jsonString:string                The JSON representation of the table
]]
function UiUtils.generateDynamicTableJsonString(tbl)
  local jsonString = "" -- The JSON string to be returned

  jsonString = jsonString.."[" -- The outer JSON object is an array

  local header = tbl[1]

  for i = 2, #tbl do -- Iterate through remaining rows
    if i ~= 2 then
      jsonString = jsonString.."," -- Only append a comma for the second non-header row onwards
    end
    
    jsonString = jsonString.."{" -- Start a new row
    for j = 1, #tbl[i] do
      if j > #header then
        error("Bad table given to UiUtils.generateDynamicTableJsonString - a row longer than the header row was found")
      end
      
      if j ~= 1 then
        jsonString = jsonString.."," -- Only append comma for second column onwards
      end
      jsonString = jsonString.."\""..header[j].."\""..":"

      if type(tbl[i][j]) == "string" then
        jsonString = jsonString.."\""..tbl[i][j].."\"" -- Enclose string objects in quotes
      elseif type(tbl[i][j]) == "number" then
        jsonString = jsonString..tostring(tbl[i][j])
      else
        jsonString = jsonString.."\"\""
      end
    end
    jsonString = jsonString.."}" -- Close the row
  end

  jsonString = jsonString.."]" -- Close the array

  return jsonString
end