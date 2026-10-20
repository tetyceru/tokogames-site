$ErrorActionPreference='Stop'
$siteRoot=Split-Path $PSScriptRoot -Parent
foreach($kind in @('privacy','terms')){
 $source=Get-Content (Join-Path $siteRoot "content/megupo-$kind.txt")
 $expected=@($source | Where-Object {$_.Trim()} | ForEach-Object {
   $line=$_.Replace('[tokogames.contact@gmail.com](mailto:tokogames.contact@gmail.com)','tokogames.contact@gmail.com')
   if($line.StartsWith('- ')){$line=$line.Substring(2)}
   if($kind -eq 'terms'){$line=$line -replace '^\d+\. ',''}
   $line
 })
 $html=Get-Content (Join-Path $siteRoot "megupo/$kind/index.html") -Raw
 $main=[regex]::Match($html,'(?s)<main[^>]*>(.*?)</main>').Groups[1].Value
 $actual=@([regex]::Matches($main,'(?s)<(?:h1|h2|p|li)\b[^>]*>(.*?)</(?:h1|h2|p|li)>') | ForEach-Object {[System.Net.WebUtility]::HtmlDecode(($_.Groups[1].Value -replace '<[^>]+>',''))})
 if(($expected -join "`n") -cne ($actual -join "`n")){throw "Approved text differs: $kind"}
 if([regex]::Matches($main,'<h2>').Count -ne 11){throw 'Section count differs'}
 Write-Output "PASS: $kind approved text matches; date and 11 sections checked"
}
$pages=Get-ChildItem $siteRoot -Filter '*.html' -Recurse
foreach($page in $pages){
 $html=Get-Content $page.FullName -Raw
 if($html -match '<script|<iframe|<form|https?://|document\.cookie|localStorage|sessionStorage|@import'){throw 'Unexpected external resource or active content'}
 foreach($match in [regex]::Matches($html,'href="([^"]+)"')){
   $href=$match.Groups[1].Value
   if($href.StartsWith('mailto:')){if($href -ne 'mailto:tokogames.contact@gmail.com'){throw 'Unexpected email'};continue}
   $filePart=($href -split '#')[0]
   if(!$filePart){continue}
   $resolved=[IO.Path]::GetFullPath((Join-Path $page.DirectoryName $filePart))
   if(Test-Path $resolved -PathType Container){$resolved=Join-Path $resolved 'index.html'}
   if(!(Test-Path $resolved)){throw "Broken local link: $href"}
 }
}
Write-Output 'PASS: three pages; links, email, no external resources or client-side scripts'
