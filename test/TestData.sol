// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/************************************************
* Author: Navinavu (https://github.com/NaviNavu)
*************************************************/

import { Vm } from "forge-std/Vm.sol";

struct Data {
    uint256 ownerPK;
    address diamondOwner;
    address defaultEOA;
}

abstract contract TestData {
    Data internal testData;
    
    constructor() {
        testData.ownerPK = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D).envUint("LOCAL_DEPLOYER_PRIVATE_KEY");
        testData.diamondOwner = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D).envAddress("DIAMOND_OWNER");
        testData.defaultEOA = address(0xDeFa);
    }
}