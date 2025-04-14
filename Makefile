#!/usr/bin/env make
#
# independ - C compiler independent formatting of C compiler dependency output
#
# Copyright (c) 2022-2023,2025 by Landon Curt Noll.  All Rights Reserved.
#
# Permission to use, copy, modify, and distribute this software and
# its documentation for any purpose and without fee is hereby granted,
# provided that the above copyright, this permission notice and text
# this comment, and the disclaimer below appear in all of the following:
#
#       supporting documentation
#       source copies
#       source works derived from this source
#       binaries derived from this source or from derived source
#
# LANDON CURT NOLL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
# INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
# EVENT SHALL LANDON CURT NOLL BE LIABLE FOR ANY SPECIAL, INDIRECT OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
# USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# chongo (Landon Curt Noll) /\oo/\
#
# http://www.isthe.com/chongo/index.html
# https://github.com/lcn2
#
# Share and enjoy!  :-)


#############
# utilities #
#############

# suggestion: List utility filenames, not paths.
#             Do not list shell builtin (echo, cd, ...) tools.
#             Keep the list in alphabetical order.
#
CHMOD= chmod
CMP= cmp
CP= cp
ID= id
INSTALL= install
RM= rm
SHELL= bash


######################
# target information #
######################

# V=@:  do not echo debug statements (quiet mode)
# V=@   echo debug statements (debug / verbose mode)
#
V=@:
#V=@

DESTDIR= /usr/local/bin

TARGETS= independ


###########################################
# all rule - default rule - must be first #
###########################################

all: ${TARGETS}
	${V} echo DEBUG =-= $@ start =-=
	${V} echo DEBUG =-= $@ end =-=


#################################################
# .PHONY list of rules that do not create files #
#################################################

.PHONY: all configure clean distclean clobber install test update_test


###########################################################
# repo tools - rules for those who maintain the this repo #
###########################################################

# perform the independ regression tests
#
test: ${TARGETS} test_independ/sample.mk test_independ/expected_sample.mk test_independ/invalid.mk \
	test_independ/expected_invalid.mk test_independ/expected_invalid.stderr
	@echo start of independ regression tests
	@echo
	./independ test_independ/sample.mk | ${CMP} -s - test_independ/expected_sample.mk
	@echo
	${RM} -f test_independ/test_invalid.mk test_independ/test_invalid.stderr
	-./independ < test_independ/invalid.mk > test_independ/test_invalid.mk 2> test_independ/test_invalid.stderr; \
	CODE="$$?"; if [[ $$CODE -ne 1 ]]; then \
	    echo "test of invalid.mk expected exit 1, found exit code: $$CODE" 1>&2; \
	    exit 10; \
	fi
	${CMP} -s test_independ/test_invalid.mk test_independ/expected_invalid.mk
	${CMP} -s test_independ/test_invalid.stderr test_independ/expected_invalid.stderr
	@echo
	@echo all independ regression tests are OK

# When independ is both working and updated, run this tool to update the expected tests results.
#
update_test: ${TARGETS} test_independ/sample.mk test_independ/invalid.mk
	${RM} -f test_independ/expected_sample.mk test_independ/expected_invalid.mk test_independ/expected_invalid.stderr
	./independ test_independ/sample.mk > test_independ/expected_sample.mk
	-./independ < test_independ/invalid.mk > test_independ/expected_invalid.mk 2> test_independ/expected_invalid.stderr; \
	CODE="$$?"; if [[ $$CODE -ne 1 ]]; then \
	    echo "test of invalid.mk expected exit 1, found exit code: $$CODE" 1>&2; \
	    exit 11; \
	fi


###################################
# standard Makefile utility rules #
###################################

configure:
	${V} echo DEBUG =-= $@ start =-=
	${V} echo DEBUG =-= $@ end =-=

clean distclean:
	${V} echo DEBUG =-= $@ start =-=
	${V} echo DEBUG =-= $@ end =-=

clobber: clean
	${V} echo DEBUG =-= $@ start =-=
	${RM} -f test_invalid.mk test_invalid.stderr
	${V} echo DEBUG =-= $@ end =-=

install: all
	${V} echo DEBUG =-= $@ start =-=
	@if [[ $$(${ID} -u) != 0 ]]; then echo "ERROR: must be root to make $@" 1>&2; exit 2; fi
	${INSTALL} -d -m 0755 ${DESTDIR}
	${INSTALL} -m 0555 ${TARGETS} ${DESTDIR}
	${V} echo DEBUG =-= $@ end =-=
