// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ContextCache} from "../src/ContextCache.sol";

struct MyCustomData {
    uint256 a;
    uint256 b;
    uint256 c;
    bytes nameOfFirstChild;
}

contract ExampleContract is ContextCache {
    function exampleViewFunction(uint256 a, uint256 b, uint256 c, bytes calldata name)
        external
        view
        returns (MyCustomData memory mcd)
    {
        bytes memory res = this.contextedExampleViewFunction(a, b, c, name);

        (mcd) = abi.decode(res, (MyCustomData));
    }

    function contextedExampleViewFunction(uint256 a, uint256 b, uint256 c, bytes calldata name)
        external
        view
        returns (bytes memory ret)
    {
        _initContextCache();
        MyCustomData memory _ret;

        // example business logic

        _exampleFunctionSettingA(a);
        _exampleFunctionSettingBNested(b);
        _exampleFunctionSettingCTwiceNested(c);
        _exampleFunctionSettingName(name);

        (bool ok, bytes memory value) = _getContextCache(bytes32("a"));
        assert(ok);
        _ret.a = abi.decode(value, (uint256));

        (ok, value) = _getContextCache(bytes32("b"));
        assert(ok);
        _ret.b = abi.decode(value, (uint256));

        (ok, value) = _getContextCache(bytes32("c"));
        assert(ok);
        _ret.c = abi.decode(value, (uint256));

        (ok, value) = _getContextCache(bytes32("name"));
        assert(ok);
        _ret.nameOfFirstChild = value; // note.. don't decode when expecting raw bytes silly

        _checkValuesAreAvailableOneLayerDown(a, b, c, name);

        // check they are accessible one frame down

        ret = abi.encode(_ret);
    }

    // a
    function _exampleFunctionSettingA(uint256 a) private view {
        _setContextCache(bytes32("a"), bytes32(a));
    }

    // b
    function _exampleFunctionSettingBNested(uint256 b) private view {
        _exampleFunctionSettingB(b);
    }

    function _exampleFunctionSettingB(uint256 b) private view {
        _setContextCache(bytes32("b"), bytes32(b));
    }

    // c
    function _exampleFunctionSettingCTwiceNested(uint256 c) private view {
        _exampleFunctionSettingCNested(c);
    }

    function _exampleFunctionSettingCNested(uint256 c) private view {
        _exampleFunctionSettingC(c);
    }

    function _exampleFunctionSettingC(uint256 c) private view {
        _setContextCache(bytes32("c"), bytes32(c));
    }

    //name
    function _exampleFunctionSettingName(bytes memory name) private view {
        _setContextCache(bytes32("name"), name);
    }

    function _checkValuesAreAvailableOneLayerDown(uint256 a, uint256 b, uint256 c, bytes memory name) public pure {
        MyCustomData memory _ret;
        (bool ok, bytes memory value) = _getContextCache(bytes32("a"));
        assert(ok);
        _ret.a = abi.decode(value, (uint256));

        (ok, value) = _getContextCache(bytes32("b"));
        assert(ok);
        _ret.b = abi.decode(value, (uint256));

        (ok, value) = _getContextCache(bytes32("c"));
        assert(ok);
        _ret.c = abi.decode(value, (uint256));

        (ok, value) = _getContextCache(bytes32("name"));
        assert(ok);
        _ret.nameOfFirstChild = value; // note.. don't decode when expecting raw bytes silly

        assert(_ret.a == a);
        assert(_ret.b == b);
        assert(_ret.c == c);
        assert(keccak256(_ret.nameOfFirstChild) == keccak256(_ret.nameOfFirstChild));
    }
}

contract ContextCacheTest is Test {
    ExampleContract ec;

    function setUp() public {
        ec = new ExampleContract();
    }

    function test() public view {
        MyCustomData memory mcd = MyCustomData(1, 2, 3, lyrics);
        MyCustomData memory _mcd = ec.exampleViewFunction(mcd.a, mcd.b, mcd.c, mcd.nameOfFirstChild);
        assertEq(_mcd.a, mcd.a);
        assertEq(_mcd.b, mcd.b);
        assertEq(_mcd.c, mcd.c);
        assertEq(keccak256(_mcd.nameOfFirstChild), keccak256(mcd.nameOfFirstChild));
    }
}

bytes constant lyrics = "A glaring light an unnatural tremor" " Suffocating heat, suffocating heat"
    " A hell on earth, hell on earth" " Men women and children groaning in agony"
    " From the intolerable pains of their burns" " A hell on earth, hell on earth";
