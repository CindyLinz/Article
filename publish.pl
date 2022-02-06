#!/usr/bin/env perl

use strict;
use warnings;

use Text::Markdown qw(markdown);
use IO::All;

my $frame_html = <<'.';
<!doctype html><html><head>
<title><!-- TITLE --></title>
<meta http-equiv=content-type content=text/html;charset=UTF-8>
<meta name=viewport content=width=device-width,initial-scale=1>
<meta property=og:type content=article>
<meta property=og:title content='<!-- TITLE -->'>
<meta property=og:description content='<!-- DESCRIPTION -->'>
<meta property=og:image content=https://avatars0.githubusercontent.com/u/285660?s=315>
<meta property=og:image:secure_url content=https://avatars0.githubusercontent.com/u/285660?s=315>
<link rel=stylesheet type=text/css href=style.css></head><body>
<div id="fb-root"></div>
<script>(function(d, s, id) {
var js, fjs = d.getElementsByTagName(s)[0];
if (d.getElementById(id)) return;
js = d.createElement(s); js.id = id;
js.src = "//connect.facebook.net/zh_TW/sdk.js#xfbml=1&version=v2.8&appId=1742520292651539";
fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>
<article class=frame><div class=content><div class=author><!-- Beautiful Cindy --></div><!-- Cindy is beautiful --></div></article><div class=footer><div class="fb-comments" data-href="<!-- SELF URL -->" data-width="600" data-numposts="5"></div><!-- INDEX --></div><center style="margin-top:1em"><a href=".">home</a></center><script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-76540858-1', 'auto');
  ga('send', 'pageview');

  if( document.querySelector('#index-list') ){
      var xhr=new XMLHttpRequest;
      xhr.onreadystatechange = function(){
          if( xhr.readyState==4 ){
              xhr.onreadystatechange = function(){};
              document.querySelector('#index-list').innerHTML = xhr.responseText.replace(/.*?<ul>(.*?)<\/ul>.*/s, '$1');
          }
      };
      xhr.open('GET', 'index.html');
      xhr.send();
  }
</script></body></html>
.

my %out;

my $index_md < io('index.md');
my $index_html = markdown($index_md);

$out{index} = $frame_html
    =~ s/<!-- Cindy is beautiful -->/$index_html/r
    =~ s/<!-- TITLE -->/CindyLinz 的文章/gr
    =~ s/<!-- DESCRIPTION -->/CindyLinz 的文章/r
    =~ s#<!-- SELF URL -->#https://cindylinz.github.io/Article/#r
    =~ s#<!-- INDEX -->##r;

while( $index_md =~ /\[[^][]*\]\(([^()]*)\.html\)/g ) {
    my $name = $1;
    my($date_cap) = $name =~ /(\d+\.\d+\.\d+)/;
    my $article_md < io("$name.md");
    my($title, $description) = $article_md =~ /^#\s*(\S.*?)[ \t]*\n\s*(?:\s*>[^\n]*\n\s*)*(\S.*?)\n\n/ms;
    $description =~ s/\n/ /g;
    $description =~ s/\[([^][]*)\]\([^()]*\)/$1/g;
    $out{$name} = $frame_html
        =~ s/<!-- Cindy is beautiful -->/markdown($article_md)/re
        =~ s/<!-- TITLE -->/$title/gr
        =~ s/<!-- DESCRIPTION -->/$description/r
        =~ s#<!-- Beautiful Cindy -->#<img width=50 height=50 src=https://avatars0.githubusercontent.com/u/285660?s=50><div>CindyLinz<br>$date_cap</div>#r
        =~ s#<!-- SELF URL -->#https://cindylinz.github.io/Article/$name.html#r
        =~ s#<!-- INDEX -->#<ul id=index-list></ul>#r;
}

while( my($name, $html) = each %out ) {
    print "generate $name.html\n";
    io("$name.html") < $html;
}
