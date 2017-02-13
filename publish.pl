#!/usr/bin/perl

use strict;
use warnings;

use Text::Markdown qw(markdown);
use IO::All;

sub sys {
    my($cmd) = @_;
    print $cmd, $/;
    system($cmd);
}

sys('git checkout master');

my $frame_html = <<'.';
<!doctype html><html><head><link rel=stylesheet type=text/css href=style.css></head><body><article class="frame"><div class="author"><!-- Beautiful Cindy --></div><div class="content"><!-- Cindy is beautiful --></div></article><center style="margin-top:1em"><a href="/">home</a></center><script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-76540858-1', 'auto');
  ga('send', 'pageview');
</script></body></html>
.

my %out;

my $index_md < io('index.md');

$out{index} = $frame_html =~ s/<!-- Cindy is beautiful -->/markdown($index_md)/re;

while( $index_md =~ /\[[^][]*\]\(([^()]*)\.html\)/g ) {
    my $name = $1;
    my($date_cap) = $name =~ /(\d+\.\d+\.\d+)/;
    my $article_md < io("$name.md");
    $out{$name} = $frame_html =~ s/<!-- Cindy is beautiful -->/markdown($article_md)/re =~ s#<!-- Beautiful Cindy -->#"<img width=50 height=50 src=https://avatars0.githubusercontent.com/u/285660?s=50><div>CindyLinz<br>$date_cap</div>"#re;
}

sys('git checkout gh-pages');

while( my($name, $html) = each %out ) {
    io("$name.html") < $html;
}
