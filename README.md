# pdfreplacetxt

Use this utility to replace text in a PDF file without having to edit the file with a bespoke PDF editor. This can only do basic replacements using regular expressions such as you might use on a text file using the 'sed' command e.g.

	sed -e 's/[search pattern]/[replacement pattern]/' -i textfile

The equivalent for a PDF file is:

	pdfreplacetxt file.pdf "[search pattern]" "[replacement pattern]"

# Watch out for:

- Do not assume that line breaks inside a PDF file are going to be where they appear when a PDF viewer displays a PDF file. It is therefore important not to use open-ended regexes such as \"*. etc\" for a search pattern. Generally, be very specific what you are looking for to replace. Just like normal 'SED', this 'SED' does not span across lines either.
- If the replacement string is much longer than the searched-for string, the resulting document may loose some of its formatting.
- If the letters in a word in the searched-for string are written in different fonts or sizes or offsets, the chances are pretty slim that the searched-for string will be found.
- In rare cases, the text to be removed is encapsulated inside a font in the PDF file, so can't readily be identified in order for it to be removed using this process.
- Sometimes a PDF file contains an entire bitmap image and no text. This is especially the case for PDF documents that were created from scannned paper documents. This utility will not help in such cases.
- Take care not to specify a PDF control term to be replaced, as this can potentially corrupt your entire PDF file.

# Prerequisites:

You need to have the PDF Toolkit installed, a.k.a. "pdftk". Depending on your Linux distro, use one of the following installation commands depending on what version of Linux you have:

    yum install pdftk
    apt-get install pdftk
    emerge pdftk

# Usage:

    pdfreplacetxt ebook.pdf "09 October" "10 October"

# Installation:

Copy these files into your /usr/local/bin directory

    $ sudo cp pdfreplacetxt* /usr/local/bin

# Example:

To change the face-value of a PDF cheque (that a "check" to you lot in America) from $100 to $1000, do could do this (but you shouldn't):

    pdfreplacetxt cheque.pdf "100\.00" "1000\.00"
    pdfreplacetxt cheque.pdf "HUNDRED" "THOUSAND"

BTW, don't do this, it's called fraud. I am using this as an example:

- To illustrate that most PDF documents are not secured and can easily be adulterated.
- Because cheques should not be used as a modern payment method anyway. Cheques and the people who use them are both stupid. And the banks that still advocate cheques are greedy.

To become a Big-Time criminal and apply this to all the $100 cheques in a directory tree, do this to secure your place in jail next to Bernie Madoff:

    find . -name "*.pdf" -exec pdfreplacetxt {} "100\.00" "1000\.00" \; -print
    find . -name "*.pdf" -exec pdfreplacetxt {} "HUNDRED" "THOUSAND" \; -print

# Author:

Gerrit Hoekstra. You can contact me via https://github.com/gerritonagoodday

# Environmental Notice:

This work was created from 100%-recycled electrons. No animals were hurt during the production of this work, except when I forgot to feed my cats that one time. The cats and I are on speaking terms again.
