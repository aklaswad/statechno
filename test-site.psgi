use Data::Section::Simple qw/ get_data_section /;;
my $html = do { local $/; <DATA> };
my $static = get_data_section;
my $app = sub {
    my $env = shift;
    my $path = $env->{PATH_INFO} || '/';
    return [ 200, [], [$static->{$path}] ] if $static->{$path};
    my $status = int( $path ? substr( $path, 1,3 ) : 0 );
    return [200 <= $status && $status < 600 ? $status : 404, [], [] ];
};

__DATA__

@@ /
<!DOCTYPE html>
<title>statechno test</title>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
<script src="/js"></script>
<link rel="stylesheet" href="/style" />
<p>
  <button data-status="200">200</button>
  auto <input data-status="200" type="checkbox" /> <input class="status-200" value="1" /> per second
</p>
<p>
  <button data-status="400">400</button>
  auto <input data-status="400" type="checkbox" /> <input class="status-400" value="1" /> per second
</p>
<p>
  <button data-status="500">500</button>
  auto <input data-status="500" type="checkbox" /> <input class="status-500" value="1" /> per second
</p>

@@ /js
$( function () {
  var callit = function (status) {
    if( !status ) status = 100 +  Math.ceil(Math.random() * 4) * 100;
    $.get('/' + status);
  };

  $('button').click( function(){
    callit( $(this).text() );
  });
  $('input[type=checkbox]').bind('change', function () {
    if ( $(this).is(':checked') ) {
      var $that = $(this);
      var status = $that.attr('data-status');
      var runner = function () {
        callit(status);
        if ( $that.is(':checked') ) {
          var rps = parseInt( $('.status-' + status).val() );
          if (rps <= 0 ) rps = 0.0001;
          setTimeout( runner, 1000 / rps );
        }
      };
      runner();
    }
  });

});

@@ /style
.body {
  color: #333;
}
