// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity ^0.8.25;

import "./MemoryMappings.sol";

contract ContextCache {
    /*

     Usage pattern. See tests for examples.
     This pattern is important as it is necesarry to line up the cache memory location
     so it can be accessed anytime, anywhere in the context

     // note: since keys are somewhat arbitrary (can be strings so are essentially not typed), 
          be sure you have in place a well reasoned key naming scheme in your codebase

     // any external view function
     function someFunction(
        ...primitiveArgs.. callDataArgs .. memory args OK 
     ) external view returns(.. any args even memory..) {
        bytes memory res = this.contextedSomeFunction()
        (.. returnArgs ..) = abi.decode(res, (.. returnArgsTypes ...));
     }

     function contextedSomeFunction(
        ...primitiveArgs.. callDataArgs .. memory args OK if directly from params of caller 
     ) external view returns(bytes memory ret) {
        _initContextCache();
        // business logic

        ret = abi.encode(.. args returned by calling function ...);
     }
     
     **/

    // always init this first in a context
    // never use with modifiers
    // VERY sensitive to memory declared return variables!! so must use "this.contextedExampleFunction" pattern.. see above
    function _initContextCache() internal view {
        // this "always" gives a ptr at memory 448
        MemoryMappings.MemoryMapping memory mm = MemoryMappings.newMemoryMapping({sorted: false, overwrite: true});
        uint256 ptr;
        assembly {
            ptr := mm
        }
        assert(msg.sender == address(this)); // since called using pattern stated above
        assert(ptr == 448);
    }

    function _getContextCache(bytes32 key) internal pure returns (bool ok, bytes memory value) {
        MemoryMappings.MemoryMapping memory cache = _getContextCache();
        return MemoryMappings.get(cache, key);
    }

    function _setContextCache(bytes32 key, bytes32 value) internal pure {
        MemoryMappings.MemoryMapping memory cache = _getContextCache();
        MemoryMappings.add(cache, key, value);
    }

    function _setContextCache(bytes32 key, bytes memory value) internal pure {
        MemoryMappings.MemoryMapping memory cache = _getContextCache();
        MemoryMappings.add(cache, key, value);
    }

    function _getContextCache() private pure returns (MemoryMappings.MemoryMapping memory cache) {
        assembly {
            cache := 448
        }
    }
}
