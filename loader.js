(function(){
  var ajax = function(url, cb){
    var xhr = new XMLHttpRequest;
    xhr.onreadystatechange = function(){
      if( xhr.readyState==4 ){
        xhr.onreadystatechange = new Function('');
        cb(xhr.responseText);
      }
    };
    xhr.open('GET', url);
    xhr.send(null);
  };

  ajax('style.css', function(css){
    var style = document.createElement('style');
    style.innerHTML = css;
    document.head.appendChild(style);
  });

  var marked;
  var article_src;

  var render_article = function(){
    document.body.querySelector('.content').innerHTML = marked(article_src);
  };

  ajax('marked.js', function(marked_src){
    var define_marked = function(get_marked){
      marked = get_marked();
    };
    define_marked.amd = true;
    (new Function('define', marked_src))(define_marked);

    var renderer = new marked.Renderer();
    renderer.blockquote = function(str){
      return "<blockquote>" + str + "</blockquote>";
    };

    marked.setOptions({
      renderer: renderer,
      gfm: true
    });

    if( article_src )
      render_article();
  });

  window.article = function(name){
    ajax(name + '.md', function(text){
      article_src = text;
      if( marked )
        render_article();
    });
  };

  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-76540858-1', 'auto');
  ga('send', 'pageview');

  window.onload = function(){
    document.body.innerHTML = '<article class=frame><div class=author></div><div class=content></div></article><center style=margin-top:1em><a href=article.html?entry=index.md>home</a></center>';

    var entry_match = (''+window.location).match(/entry=((\d+\.\d+\.\d+)?[^\/]*)\.md|\/((\d+\.\d+\.\d+)?[^\/]*)\.html(?!.*entry=)/);
    if( entry_match ){
      var date_cap = entry_match[2] || entry_match[4];
      if( date_cap )
        document.body.querySelector('.author').innerHTML = '<img width=50 height=50 src=https://avatars0.githubusercontent.com/u/285660?s=50><div>CindyLinz<br>' + date_cap + '</div>';
      var name_cap = entry_match[1] || entry_match[3];
      article(name_cap);
    }
  };
})();
