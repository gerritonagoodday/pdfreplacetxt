#!/bin/bash
PROGNAME=${0##*/}
STARTTIME=$(date +%s)

function Usage {
  printf "
Usage:
  ${0##*/} filepath.pdf \"search pattern\" \"replacement pattern\"

Function:
  Use this utility to replace text in a PDF file without having to edit the
  file with a PDF editor. This can only do basic replacements using regular
  expressions such as you might use on a text file using the 'sed' command
  e.g. sed -e 's/[search pattern]/[replacement pattern/' -i textfile

  Do not assume that line breaks inside a PDF file are going to be where they
  appear when a PDF viewer displays a PDF file. It is therefore important not
  to use open-ended regexes such as \"*. etc\" for a search patternn.

Example:
  pdfsed ebook.pdf \"09 October\" \"10 October\"

Author:
  Gerrit Hoekstra. You can contact me via https://github.com/gerritonagoodday
"
  exit 1
}

function die {
  if [[ -z $1 ]]; then
    printf "$(tput setaf 9)failed.\nExiting...\n$(tput sgr 0)"
  else
    printf "$(tput setaf 9)*** $1 ***\nExiting...\n$(tput sgr 0)"
  fi
  exit 1
}
function warn {
  printf "$(tput setaf 3)Warning: $1\n$(tput sgr 0)"
}
function info {
  printf "$(tput setaf 10)$1...\n$(tput sgr 0)"
}
function doneit {
  if [[ -n $1 ]]; then
    printf "$(tput setaf 12)$1, done\n$(tput sgr 0)"
  else
    printf "$(tput setaf 12)done\n$(tput sgr 0)"
  fi
}

[[ $# -ne 3 ]] && Usage
PDFFILE="${1}"
[[ -z "$PDFFILE" ]] && Usage
SEARCHPATTERN="${2}"
[[ -z "$SEARCHPATTERN" ]] && Usage
REPLACEMENTPATTERN="${3}"

# Temp work files
TMPFILE1="$(mktemp --tmpdir "${PROGNAME}.$$.XXXXXX")"

#============================================================================#
# Set traps and signal BEGIN and END
# Need logging to work for this
#============================================================================#
function cleanup {
  rm "${TMPFILE1}" 2>/dev/null
  ENDTIME=$(date +%s)
  elapsedseconds=$((ENDTIME-STARTTIME))
  s=$((elapsedseconds % 60))
  m=$(((elapsedseconds / 60) % 60))
  h=$(((elapsedseconds / 60 / 60) % 24))
  duration=$(printf "Duration (h:m:s): %02d:%02d:%02d" $h $m $s)
  doneit "${duration}"
  exit
}
for sig in KILL TERM INT EXIT; do trap 'cleanup $sig' "$sig" ; done

info "Checking environment"
PDFTK="$(which pdftk 2>/dev/null)"
[[ -z "$PDFTK" ]] && die "pdftk does not appear to be installed."
info "Checking $PDFFILE"
[[ ! -f "$PDFFILE" ]] && die "$PDFFILE does not exist"
filetype=$(file -b "$PDFFILE")
if [[ $filetype =~ ^PDF ]]; then
  info "$PDFFILE is a PDF file"
else
  die "File $PDFFILE does not appear to be a PDF file."
fi

info "Uncompressing $PDFFILE"
pdftk "$PDFFILE" output "$TMPFILE1" uncompress  > /dev/null 2>&1
retcode=$?
[[ $retcode -ne 0 ]] && die "pdftk returned error code $retcode"

info "Replacing '$SEARCHPATTERN' with '$REPLACEMENTPATTERN' in $PDFFILE"
# Fix patterns with deal with PDF formatting codes
SEARCHPATTERN="$(echo "$SEARCHPATTERN" | sed -e 's/ /.*/g')"
# Deal with patterns that contains actual speech marks
SEARCHPATTERN="$(echo "$SEARCHPATTERN" | sed -e "s|'|\x27|g" | sed -e 's/"/\x22/g')"
REPLACEMENTPATTERN="$(echo "$REPLACEMENTPATTERN" | sed -e "s|'|\x27|g" | sed -e 's/"/\x22/g')"
sed -e "s|${SEARCHPATTERN}|${REPLACEMENTPATTERN}|g" -i "$TMPFILE1"

info "Re-Compressing $PDFFILE"
pdftk "$TMPFILE1" output "$PDFFILE" compress > /dev/null 2>&1
retcode=$?
[[ $retcode -ne 0 ]] && die "pdftk returned error code $retcode"
