----------------------------------------------------------------------------------------------------
-- Scripting Parameters
----------------------------------------------------------------------------------------------------

-- local LuaDebug   = require 'LuaDebugging'
-- LuaDebugging  = true   --> Override the global LuaDebugging variable by uncommenting this line.
-- LuaStatistics = true   --> Override the global LuaStatistics variable by uncommenting this line.


----------------------------------------------------------------------------------------------------
-- Local Constants
----------------------------------------------------------------------------------------------------

DirectoryPagination = '/p/blog-page.html'


----------------------------------------------------------------------------------------------------
-- Event Functions
----------------------------------------------------------------------------------------------------

-- Get info and chapter list for current manga.
function GetInfo()
  local x = nil
  local u = MaybeFillHost(MODULE.RootURL, URL)
  
  --[[Debug]] LuaDebug.WriteLogWithHeader('GetInfo', 'URL ->  ' .. u)
  if not HTTP.GET(u) then return net_problem end
  
  x = TXQuery.Create(HTTP.Document)
  MANGAINFO.Title     = Trim(x.XPathString('//title/substring-before(., " - ReadKomik")'))
  if MANGAINFO.Title  == "" then MANGAINFO.Title = Trim(x.XPathString('//title/substring-after(., "ReadKomik: ")')) end
  MANGAINFO.CoverLink = x.XPathString('//div[@class="kerangka-gambar"]//a/@href')
  MANGAINFO.Status    = MangaInfoStatusIfPos(x.XPathString('//td[contains(., "Status")]/following-sibling::td'))
  MANGAINFO.Genres    = x.XPathString('//td[contains(., "Genre")]/following-sibling::td')
  MANGAINFO.Summary   = x.XPathString('//div[@class="isi-sinopsis"]')
  
  for _, v in ipairs(x.XPathI('//*[@dir="ltr" or @class="tabel-chapter"]/a')) do
    MANGAINFO.ChapterNames.Add(x.XPathString('span', v))
    MANGAINFO.ChapterLinks.Add(v.GetAttribute('href'))
  end
  if MANGAINFO.ChapterLinks.Count < 1 then
    x.XPathHREFAll('//div[contains(@itemprop, "description")]/a', MANGAINFO.ChapterLinks, MANGAINFO.ChapterNames)
  end
  if MANGAINFO.ChapterLinks.Count < 1 then
    x.XPathHREFAll('//h2[@class="entry-title"]/a', MANGAINFO.ChapterLinks, MANGAINFO.ChapterNames)
  end
  
  --[[Debug]] LuaDebug.PrintMangaInfo()
  --[[Debug]] LuaDebug.WriteStatistics('Chapters', MANGAINFO.ChapterLinks.Count .. '  (' .. MANGAINFO.Title .. ')')
  
  return no_error
end


-- Get LINKS and NAMES from the manga list of the current website.
function GetNameAndLink()
  local x = nil
  local u = MODULE.RootURL .. DirectoryPagination
  
  --[[Debug]] LuaDebug.WriteLogWithHeader('GetNameAndLink', 'URL ->  ' .. u)
  if not HTTP.GET(u) then return net_problem end
  
  x = TXQuery.Create(HTTP.Document)
  x.XPathHREFAll('//div[contains(@itemprop, "description")]/a', LINKS, NAMES)
  
  --[[Debug]] LuaDebug.PrintMangaDirectoryEntries(1)
  
  return no_error
end


-- Get the page count for the current chapter.
function GetPageNumber()
  local x = nil
  local u = MaybeFillHost(MODULE.RootURL, URL)
  
  --[[Debug]] LuaDebug.WriteLogWithHeader('GetPageNumber', 'URL ->  ' .. u)
  if not HTTP.GET(u) then return net_problem end
  
  x = TXQuery.Create(HTTP.Document)
  x.XPathStringAll('//div[@class="separator"]/a/@href', TASK.PageLinks)
  
  --[[Debug]] LuaDebug.PrintChapterPageLinks()
  --[[Debug]] LuaDebug.WriteStatistics('ChapterPages', TASK.PageLinks.Count .. '  (' .. u .. ')')
  
  return no_error
end


----------------------------------------------------------------------------------------------------
-- Module Initialization
----------------------------------------------------------------------------------------------------

function Init()
  local m = NewWebsiteModule()
  m.ID                       = 'f19d56bb21ea46bea8bee5b9c083d4d0'
  m.Name                     = 'ReadKomik'
  m.RootURL                  = 'https://www.readkomik.com'
  m.Category                 = 'Webcomics'
  m.OnGetInfo                = 'GetInfo'
  m.OnGetNameAndLink         = 'GetNameAndLink'
  m.OnGetPageNumber          = 'GetPageNumber'
end