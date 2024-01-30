// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {BaseTest} from "../BaseTest.t.sol";
import {GasBadNftMarketplace} from "../../src/GasBadNftMarketplace.sol";

contract GasBadNftMarketplaceTest is BaseTest {
    function setUp() public override {
        super.setUp();
        nftMarketplace = new GasBadNftMarketplace();
    }
}
