$ErrorActionPreference='Stop'
$siteRoot=Split-Path $PSScriptRoot -Parent
function Escape([string]$value){[System.Net.WebUtility]::HtmlEncode($value)}
function Inline([string]$value){(Escape $value).Replace('[tokogames.contact@gmail.com](mailto:tokogames.contact@gmail.com)','<a href="mailto:tokogames.contact@gmail.com">tokogames.contact@gmail.com</a>')}
function Build-Legal([string]$kind,[string]$other,[string]$otherTitle){
  $lines=Get-Content -LiteralPath (Join-Path $siteRoot "content/megupo-$kind.txt")
  $title=Escape $lines[0]
  if($lines[1] -ne '制定日：2026年10月20日'){throw 'Unexpected enactment date'}
  $blocks=[System.Collections.Generic.List[string]]::new()
  $list=''
  foreach($line in $lines | Select-Object -Skip 2){
    if(!$line.Trim()){continue}
    $heading=($kind -eq 'privacy' -and $line -match '^\d+\. ') -or ($kind -eq 'terms' -and $line -match '^第\d+条')
    $nextList=if($line -match '^- '){'ul'}elseif($kind -eq 'terms' -and $line -match '^\d+\. '){'ol'}else{''}
    if($list -and $list -ne $nextList){$blocks.Add("</$list>");$list=''}
    if($nextList){
      if(!$list){$blocks.Add("<$nextList>");$list=$nextList}
      $text=$line -replace '^(?:- |\d+\. )',''
      $blocks.Add('<li>'+(Inline $text)+'</li>')
    }elseif($heading){$blocks.Add('<h2>'+(Escape $line)+'</h2>')}
    else{$blocks.Add('<p>'+(Inline $line)+'</p>')}
  }
  if($list){$blocks.Add("</$list>")}
  $body=$blocks -join "`n"
  $page=@"
<!doctype html>
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title | Toko Games</title>
<meta name="description" content="Toko Gamesが提供する$title。">
<link rel="stylesheet" href="../../assets/site.css">
</head>
<body>
<a class="skip" href="#main">本文へ移動</a>
<header class="site-header"><a href="../../">Toko Games</a></header>
<main id="main" class="legal">
<h1>$title</h1>
<p class="date"><time datetime="2026-10-20">制定日：2026年10月20日</time></p>
$body
</main>
<footer><nav aria-label="関連ページ"><a href="../../">トップページ</a><a href="../$other/">$otherTitle</a><a href="../../#contact">問い合わせ先</a></nav><p>Toko Games</p></footer>
</body>
</html>
"@
  $page | Set-Content -LiteralPath (Join-Path $siteRoot "megupo/$kind/index.html") -Encoding utf8
}
Build-Legal 'privacy' 'terms' 'めぐポ 利用規約'
Build-Legal 'terms' 'privacy' 'めぐポ プライバシーポリシー'
Write-Output 'Built both legal pages from the approved source text.'
