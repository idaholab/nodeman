# Welcome!

My name is Scott Serr.  I've been a sysadmin for HPC clusters in the 300-1000 node range.  I created this tool because I was reinventing scripts and one-liners to do similar things.  My reasons for creating this tool may not translate to it being useful for other people or other situations.

This tool is not dead simple to setup, sorry about that.  It's all bash, so it's easy to modify.  For setup, you'll create a config file in site_config by copying the example there.

It relies on `GNU parallel`.  `GNU parallel` works well, but I use a small subset of it's capabilities.  I have 2 problems with it.  (1) users having to agree to the citation is an extra step and causes confusion.  (2) it insists on adding a tab `(\t)` in the output between the tagstring and the output.  I would be happy to entertain using something other than `GNU parallel` for the parallelization function.  If someone has suggestions please let me know.
