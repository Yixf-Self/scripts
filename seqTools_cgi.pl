#!/usr/bin/perl 

#seqTools_cgi.pl

use warnings;

use CGI qw/:standard/;

&cgi_form;
exit;

sub cgi_form {
    print header,
      start_html('seqTools - A similar webtool developed by lh3'),    ## title
      h3('seqTools'), p('Input seq in FASTA format.'), start_form, 'Command:',
      popup_menu(
        -name   => 'command',
        -values => [ 'format', 'revcom', 'length', 'content', 'search' ]
      ),
      'Search Pattern:',
      textfield('pattern'), p,
      textarea( 'data', '', 15, 80 ), p,
      submit,
      end_form;
    if (param) {
        ## 提交后
        $command = param('command');
        $data    = param('data');
        $pattern = param('pattern');

        $tmp_file = '/tmp/' . int( rand(1000000000) );

        #$tmp_file = int(rand(1000000000)); #保存在临时文件
        open( OUT, '>', "$tmp_file" ) || die;
        print OUT $data;
        close OUT;

        print b($command), p,

          #$tmp_file,p,
          #pre($data);
          ;
        print "<pre>";
        if ( $command eq 'search' ) {
            system("perl seqTools_v1.1.pl $command -i $tmp_file -p $pattern");
        }
        else {
            system("perl seqTools_v1.1.pl $command -i $tmp_file");
        }
        print "</pre>";
        unlink $tmp_file;    ## 删除临时文件
    }
    print end_html;
}

