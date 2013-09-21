my $app = sub {
    my $env = shift;
    my $path = $env->{PATH_INFO};
    my ($status) = $path =~ m{/(\d\d\d)};
    $status = int($status);
    return [ 100 <= $status && $status < 600 ? $status : 200, [], [$html]] if $status;

    my $html = <<'EOT';
<!DOCTYPE html>
<title>hello?</title>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
<script>
$( function () {
  var req = new XMLHttpRequest();
  var callit = function (status) {
    if( !status ) status = 100 +  Math.ceil(Math.random() * 4) * 100;
    $.get('/' + status);
//    setTimeout(callit, Math.floor(Math.random() * 200));
  };


  $('button').click( function(){
    callit( $(this).text() );
  });

});
</script>
hello?

<button>200</button>
<button>400</button>
<button>500</button>
EOT
    print STDERR "$status\n";
    return [ 200, [], [$html]];
};
