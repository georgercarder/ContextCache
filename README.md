## ContextCache


A pattern to cheaply replicate tstore functionality in a staticcall context.

PERFECT for use in view functions requiring lots of intermediate caching of processed data.

In fact, exceeds tstore functionality since tstore maps WORD to WORD.

But ContextCache maps WORD to WORD, or WORD to bytes.

To run tests just call `forge test -vv`

Usage:

Just inherit the `ContextCache` into any contract where you need this functionality, 
and follow the usage pattern outlined in the comments of the `ContractCache` contract
and the test.


Open to dev and security contract work. Shoot me an email.

[georgercarder@gmail.com](georgercarder@gmail.com)

Support my work on this library by donating ETH or other coins to

0x1331DA733F329F7918e38Bc13148832D146e5adE

