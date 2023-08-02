# Sources for the www.perl.org.il site

These are the sources for the [Israeli Perl Mongers’ site](http://perl.org.il/)
also known as “Israel.pm” or “Perl-IL”. We are part of the international
[Perl Mongers](https://www.pm.org/).

## Instructions for building the site:

To re-generate the web site on my development machine:

```
mkdir _site
cd site/
cpanm --notest --installdeps .
perl new_site_bin/update_site.pl --repo . --outdir ../_site
cp -r YAPC ../_site/
```

Use some static site server. e.g. download https://rustatic.code-maven.com/ and then run

```
rustatic --path _site/ --indexfile index.html
```

