# independ
C compiler independent formatting of Makefile dependency lines


## Why use independ?

This tool formats C compiler dependency output in a C compiler independent way.

C compilers such as gcc and clang use flags such as -MM to output C compiler
dependencies such as:

```make
foo.o: bar.h baz.h curds.h something.h otherthing.h anotherthing.h foo.h \
  whey.h fizzbin.h
baz.o: header.h bar.h curds.h whey.h tuffett.h spider.h foobar.h eek.h baz.h \
  details.h moredetails.h evenmoredetails.h lessdetails.h evenlessdetails.h \
  eek.h meep.h pheep.h greple.h somefile.h whonamedthisfile.h wedontknow.h \
  theyleftthecompany.h wearetoolazytorename.h theseverylonguselessfilenames.h \
  fizzbin.h morefizzbin.h fizzbin-rules.h random-rules.h rules.h norule6.h \
  fizzbin.h wik.h also-wik.h also-also-wik.h majestik-moose.h a-moose-once.h \
  bit-my-sister.h mynd-you.h moose-bites-kan-be-pretti-nasti.h
foo.o: zzz.h
baz.o: eek-as-beep.h meep-as-ascii-bell.h bar_h.h meep-beep.h
```

While both gcc and clang support -MM, the output they produce is slightly
different.  Different compilers have different indentation rules for long
dependency lines.  The order that dependency files are printed may be different
for different compilers.  In some cases the same dependency file may be printed
more than once.  In some cases, different versions of the same compiler will
produce different -MM output.

One problem with different dependency outputs us that doing "make depend"
will produce different Makefile on different systems.  This changing dependency
output results in needless changes to the Makefile when no actual dependency
changes actually occurred.

By piping Makefile dependency lines through this filter, you will have
consistent Makefile dependency lines across all of your systems.

Given the above Makefile dependency lines, independ will, by default, always print:

```make
baz.o: a-moose-once.h also-also-wik.h also-wik.h bar.h bar_h.h baz.h \
    bit-my-sister.h curds.h details.h eek-as-beep.h eek.h evenlessdetails.h \
    evenmoredetails.h fizzbin-rules.h fizzbin.h foobar.h greple.h header.h \
    lessdetails.h majestik-moose.h meep-as-ascii-bell.h meep-beep.h meep.h \
    moose-bites-kan-be-pretti-nasti.h moredetails.h morefizzbin.h \
    mynd-you.h norule6.h pheep.h random-rules.h rules.h somefile.h spider.h \
    theseverylonguselessfilenames.h theyleftthecompany.h tuffett.h \
    wearetoolazytorename.h wedontknow.h whey.h whonamedthisfile.h wik.h
foo.o: anotherthing.h bar.h baz.h curds.h fizzbin.h foo.h otherthing.h \
    something.h whey.h zzz.h
```

Notice that the dependency targets are in sorted order.  Moreover
the list of dependency files are also sorted.  Duplicate targets
are combined into a single target, and duplicate dependencies
dependency files are eliminated.


## Command line

```
usage: ./independ [-h] [-v lvl] [-V] [-i str] [-c columns] [file]

	-h		print this usage message and VERSION string and exit 0
	-v lvl		verbose / debugging level (def: 0)
	-V		print version and exit 0
	-i str		indent continued lines with str (def: "    ")
			NOTE: A tab in str is counted as a column width of 8.

	-c columns	try to limit dependency lines to columns chars, 0 ==> no limit (def: 76)

			NOTE: If a dependency filename is extremely long (relative to columns), then
			      the filename will be printed, after the indent (and followed by possible
			      space backslash, even if such a line is too long.  In all other cases lines
			      will not exceed a width of columns.

	file		File to read (def: stdin)

			NOTE: If specify reading from stdin, either supply no file argument, or
			      end command line with: -- -

NOTE: Empty lines, lines with only whitespace, and lines beginning with # are ignored.
      Lines that end with  (backslash) are assumed to be continued on the next line.
      If a Makefile dependency rule does not start with a filename followed by a : (colon),
      or if Makefile dependency rule has more than one : (colon), a warning message is
      printed on stderr and that line is ignored.

Exit codes:
     0   all is well
     1   some warning about invalid lines was printed
     2   cannot open filename for reading
     3   -h and help string printed or -V and version string printed
     4   command line error
 >= 10   internal error

Version: .. the current version string ..
```


## To install

To install independ:

```sh
# cleanup old files and form independ
make clobber all

# run the independ test suite
make test

# install independ (this usually requires superuser / root)
sudo -s make install
```


## Examples

By default, independ reads C compiler dependency text on stdin
and writes the dependency rules in stdout in canonical form.

```sh
cc prog.c prog2.c other_prog.c -MM | independ
```

Here is the recommended way to use independ in your Makefile.

Set these Makefiles early in your Makefile:

```make
CC= cc			# or whatever you call your C compiler
CFLAGS= ... your compiler flags such as -O3 -g3 ...
GREP= grep
INDEPEND= independ
RM= rm
SED= sed
SHELL= bash

ALL_CSRC= ... list of C source files ...
```

Put these lines at the very end of your Makefile:

```make
depend: ${ALL_CSRC}
	@HAVE_INDEPEND="`type -P ${INDEPEND}`"; if [[ -z "$$HAVE_INDEPEND" ]]; then \
	    echo 'The independ command could not be found.' 1>&2; \
	    echo 'The independ command is required to perform: make $@'; 1>&2; \
	    echo ''; 1>&2; \
	    echo 'See the following GitHub repo for where to obtain independ:'; 1>&2; \
	    echo ''; 1>&2; \
	    echo '    https://github.com/lcn2/independ'; 1>&2; \
	else \
	    if ! ${GREP} -q '^### DO NOT CHANGE MANUALLY BEYOND THIS LINE$$' Makefile; then \
	        echo "make $@ aborting, Makefile missing: ### DO NOT CHANGE MANUALLY BEYOND THIS LINE" 1>&2; \
		exit 1; \
	    fi; \
	    ${SED} -i.orig -n -e '1,/^### DO NOT CHANGE MANUALLY BEYOND THIS LINE$$/p' Makefile; \
	    ${CC} ${CFLAGS} -MM ${ALL_CSRC} | ${INDEPEND} >> Makefile; \
	    if ${CMP} -s Makefile.orig Makefile; then \
		${RM} -f Makefile.orig; \
	    else \
		echo; \
		echo "Makefile dependencies updated"; \
		echo; \
		echo "Previous version may be found in: Makefile.orig"; \
	    fi; \
	fi

### DO NOT CHANGE MANUALLY BEYOND THIS LINE
```

Now run the make depend rule:

```sh
make depend
```


## Author (wik)

This tool, in 2022, was written by:

chongo (Landon Curt Noll, http://www.isthe.com/chongo/index.html) /\oo/\

Share and enjoy! :-)


## Thanks (also wik)

Thanks goes to:

- Developers of [Perl](https://www.perl.org), especially Larry Wall
- The authors of the [Perl Cookbook](https://www.oreilly.com/library/view/perl-cookbook/1565922433/), Tom Christiansen and Nathan Torkington
- The authors of the [Text::Wrap CPAN module](https://metacpan.org/pod/Text::Wrap), including David Muir Sharnoff and Tim Pierce
- [Python](http://www.montypython.com) (the British comedy troupe, not that other language which
[considers whitespace to be of syntactic importance](https://medium.com/nerd-for-tech/python-is-a-bad-programming-language-2ab73b0bda5))
- Sweden, especially the loveli lakes, the wonderful telephone system, and mani interesting furry animals, as well as [Holy Grail film credit writers](https://www.youtube.com/watch?v=SII-jhEd-a0)

NOTE: Monty Python jokes aside, you should really visit Sweden if you can, it is a wonderful country to visit!


## Disclaimer (also also wik)

No programmers who created silly filenames were sacked.
