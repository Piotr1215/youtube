# Add Header

## Add shebang to all shell scripts
:args testfiles/*.sh
:argdo 0put ='#!/usr/bin/env bash' | update

## Variations
:argdo 0r ~/templates/license.txt | update
:argdo $r ~/footer.txt | update
