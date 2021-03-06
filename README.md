# Alternative Batching Method for FAVE

This branch allows you to queue speakers for extraction from aligned textgrid outputs. 

  selectTierAndQueue.praat (in FAVE-align) modifies textgrid alignment outputs with multiple speakers to produce adjusted textgrids with tiers only associated with the desired speaker and adds these speakers to an extraction queue.
  
  The addition of queue.exp (in FAVE-extract) allows you to introduce batch functionality to any version of FAVE-extract without having to introduce any  modifications in your original code.

This branch includes praat and expect scripts, so make sure you have praat and expect installed before using it.

Readme's include all documentation from the original JoFrhwld/FAVE repository, as well as additional documentation outlining steps to take to further automate the alignment and extraction processes in batches.

----------------
## FAVE toolkits

This is a repository for the FAVE-Align and FAVE-extract toolkits.
The first commit here represents the toolkit as it was available on the FAVE website as of October 21, 2013.
The extractFormants code in the JoFrhwld/FAAV repository represents an earlier version of the code.

## FAVE website

The interactive website for utilizing FAVE can be found at [fave.ling.upenn.edu](http://fave.ling.upenn.edu/)

## Support

You can find user support for installing and using the FAVE toolkits at the [FAVE Users' Group](https://groups.google.com/forum/#!forum/fave-users).

## Contributing to FAVE
For the most part, we'll be utilizing the fork-and-pull paradigm (see [Using Pull Requests](https://help.github.com/articles/using-pull-requests)). Please send pull requests to the `dev` branch.

If you want to keep up to date on FAVE development, or have questions about FAVE development, send a request to join the [FAVE Developers' Group](https://groups.google.com/forum/#!forum/fave-dev).

## Attribution
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.22281.svg)](http://dx.doi.org/10.5281/zenodo.22281)
As of v1.1.3 onwards, releases from this repository will have a DOI associated with them through Zenodo. The DOI for the current release is [10.5281/zenodo.22281](http://dx.doi.org/10.5281/zenodo.22281). We would recommend the citation:

Rosenfelder, Ingrid; Fruehwald, Josef; Evanini, Keelan; Seyfarth, Scott; Gorman, Kyle; Prichard, Hilary; Yuan, Jiahong; 2014. FAVE (Forced Alignment and Vowel Extraction) Program Suite v1.2.2 10.5281/zenodo.22281

Use of the interactive online interface should continue to cite:

Rosenfelder, Ingrid; Fruehwald, Josef; Evanini, Keelan and Jiahong Yuan. 2011. FAVE (Forced Alignment and Vowel Extraction) Program Suite. http://fave.ling.upenn.edu.
