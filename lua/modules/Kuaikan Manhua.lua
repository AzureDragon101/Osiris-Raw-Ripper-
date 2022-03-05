function getinfo()
    mangainfo.url=MaybeFillHost(module.RootURL, url)
    if http.get(mangainfo.url) then
      x=TXQuery.Create(http.document)	
      mangainfo.title=x.xpathstring('//h3[contains(@class, "title")]')
      mangainfo.coverlink=MaybeFillHost(module.rooturl,x.xpathstring('//div[contains(@class,"imgCover")]/a/img/@src'))
      mangainfo.authors=x.xpathstring('//p[@class="nickname"]/span[contains(., "")]/em/substring-before(., "")')
      mangainfo.summary=x.xpathstring('//p[contains(@class,"comicIntro")]')
      x.xpathhrefall('//div[@id="chapter"]//ol[contains(@class, "TopicItem")]/li//a', mangainfo.chapterlinks, mangainfo.chapternames)
      return no_error
    else
      return net_problem
    end
  end
  
  function getpagenumber()
    if http.get(MaybeFillHost(module.rooturl,url)) then
      x=TXQuery.Create(http.Document)
      local s = x.xpathstring('//script[contains(., "window") and contains(., "eval")]')
      local nonce = ExecJS('var window={};'..s..';window.nonce;');
      s = x.xpathstring('//script[contains(., "var DATA")]')
      local data = ExecJS(s..';DATA;');
      local script = x.xpathstring('//script[contains(@src, "chapter")]/@src')
      if http.get(script) then
        s = StreamToString(http.document)
        s = '!function(){eval'..GetBetween('!function(){eval', '))}();', s)..'))}();'
        s = 'var W={nonce:"'..nonce..'",DATA:"'..data..'"};'..s..';JSON.stringify(_v);'
        s = ExecJS(s)
        x.parsehtml(s)
        x.xpathstringall('json(*).picture().url', task.pagelinks)
        return true
      else
        return false
      end
    else
      return false
    end
  end
  
  function BeforeDownloadImage()
    http.headers.values['Referer'] = module.rooturl
    return true
  end
  
  function getdirectorypagenumber()
    if http.GET(module.RootURL .. '/tag/0l/search/hot/page/1') then
      x = TXQuery.Create(http.Document)
      page = tonumber(x.XPathString('//span[contains(@class,"TagPages pagesBox")]/em'))
      if page == nil then page = 1 end
      page = math.ceil(page / 12)
      return no_error
    else
      return net_problem
    end
  end
  
  function getnameandlink()
    if http.get(module.rooturl..'/tag/0'..IncStr(url)) then
      TXQuery.Create(http.document).XPathHREFAll('//ul[contains(@class, "resultList cls")]/li//h3/a',links,names)
      return no_error
    else
      return net_problem
    end
  end
  
  function Init()
    m=NewModule()
    m.category='Raw'
    m.website='Kuaikan Manhua'
    m.rooturl='https://www.kuaikanmanhua.com/'
    m.lastupdated='March 5, 2022'
    m.ongetinfo='getinfo'
    m.ongetpagenumber='getpagenumber'
    m.ongetdirectorypagenumber='getdirectorypagenumber'
    m.ongetnameandlink='getnameandlink'
    m.OnBeforeDownloadImage = 'BeforeDownloadImage'
  end
  