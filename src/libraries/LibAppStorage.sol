// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "src/libraries/LibDiamond.sol";

library LibAppStorage {
    struct AppStorage {
        string app_name;
    }

    function appStorage() internal pure returns (AppStorage storage s) {
        assembly {
            s.slot := 0x0
        }
    }
}