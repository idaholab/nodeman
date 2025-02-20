# Here is a full walkthrough of the GNU parallel "will cite" process.

Since GNU parallel asks you to agree to cite their work, you'll want to get that out of the way before trying to use it -- otherwise it will continue to nag you about it.
```
$ echo test | parallel echo
Academic tradition requires you to cite works you base your article on.
If you use programs that use GNU Parallel to process data for an article in a
scientific publication, please cite:

  O. Tange (2018): GNU Parallel 2018, Mar 2018, ISBN 9781387509881,
  DOI https://doi.org/10.5281/zenodo.1146014

This helps funding further development; AND IT WON'T COST YOU A CENT.
If you pay 10000 EUR you should feel free to use GNU Parallel without citing.

More about funding GNU Parallel and the citation notice:
https://www.gnu.org/software/parallel/parallel_design.html#Citation-notice

To silence this citation notice: run 'parallel --citation' once.

test

$ parallel --citation
Academic tradition requires you to cite works you base your article on.
If you use programs that use GNU Parallel to process data for an article in a
scientific publication, please cite:

@book{tange_ole_2018_1146014,
      author       = {Tange, Ole},
      title        = {GNU Parallel 2018},
      publisher    = {Ole Tange},
      month        = Mar,
      year         = 2018,
      ISBN         = {9781387509881},
      doi          = {10.5281/zenodo.1146014},
      url          = {https://doi.org/10.5281/zenodo.1146014}
}

(Feel free to use \nocite{tange_ole_2018_1146014})

This helps funding further development; AND IT WON'T COST YOU A CENT.
If you pay 10000 EUR you should feel free to use GNU Parallel without citing.

More about funding GNU Parallel and the citation notice:
https://lists.gnu.org/archive/html/parallel/2013-11/msg00006.html
https://www.gnu.org/software/parallel/parallel_design.html#Citation-notice
https://git.savannah.gnu.org/cgit/parallel.git/tree/doc/citation-notice-faq.txt

If you send a copy of your published article to tange@gnu.org, it will be
mentioned in the release notes of next version of GNU Parallel.


Type: 'will cite' and press enter.
> will cite

Thank you for your support: You are the reason why there is funding to
continue maintaining GNU Parallel. On behalf of future versions of
GNU Parallel, which would not exist without your support:

  THANK YOU SO MUCH

It is really appreciated. The citation notice is now silenced.
```
