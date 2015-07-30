###Status
[![Build Status](https://travis-ci.org/szabgab/Perl6-Maven.png)](https://travis-ci.org/szabgab/Perl6-Maven)


The code generating the http://perl6maven.com/ site.

In order to build the pages

    * Build Rakudo Star (2015.07 worked)  http://perl6maven.com/tutorial/perl6-installing-rakudo
    * git clone https://github.com/szabgab/perl6maven.com.git
    * git clone https://github.com/szabgab/Perl6-Maven.git       (this repository)
    * cd Perl6-Maven
    * time perl6 -Ilib script/generate.p6 --outdir=/home/gabor/work/perl6maven-live.com --indir=/home/gabor/work/perl6maven.com/

It took about 3 minutes to generate all the pages using Rakudo Star 2015.07 on MacBook Air


To run all the test try:

prove -e 'perl6 -Ilib' t/

or

PERL6LIB=lib prove -v -r -j1 --exec=perl6 t


TODO: Generic web site related
-------------------------------

    * Use the data collected for the Index page to create a keyword search box just as the perl5maven site has.
    * In the index page remove the main bullet points and possibly also the secondary bullets
      instead of those add color coding for the source (article/module/tutorial/doc/syn)
    * Remove /tutorial/index and redirect it to /index
    * Unite the templates for regular pages and slides. Regular pages should have their next/previous empty.
    * Create Perl 6 module to generate Atom and RSS feed and publish it. Or is there already one?
    
    * Module to fetch list of users from a Mailman site
    * Integrate that into sending e-mails directly, set various header in the e-mail
      and include banner and instruction how to unsubscribe.
    * remove hard-coded values from the code

