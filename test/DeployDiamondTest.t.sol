// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/************************************************
* Author: Navinavu (https://github.com/NaviNavu)
*************************************************/

import { Test } from "forge-std/Test.sol";
import { DeployDiamond, DeployedContracts } from "script/DeployDiamond.s.sol";
import { IOwnershipFacet } from "src/interfaces/IOwnershipFacet.sol";
import { IDiamondLoupe } from "src/interfaces/IDiamondLoupe.sol";
import { TestData } from "test/TestData.sol";
import { FacetHelper } from "helpers/FacetHelper.sol";


contract DeployDiamondTest is Test, TestData, FacetHelper {
    bytes4[] diamondCutFacetArtifactSelectors;
    bytes4[] diamondLoupeFacetArtifactSelectors;
    bytes4[] diamondOwnershipFacetArtifactSelectors;
    DeployDiamond deployDiamondScript;
    DeployedContracts deployedContracts;

    constructor() {
        /// @dev Retrieve the function selectors from the facet JSON artifacts.
        diamondCutFacetArtifactSelectors = _getSelectorsFromArtifact("DiamondCutFacet");
        diamondLoupeFacetArtifactSelectors = _getSelectorsFromArtifact("DiamondLoupeFacet");
        diamondOwnershipFacetArtifactSelectors = _getSelectorsFromArtifact("OwnershipFacet");

        /// @dev Deploy and run the DiamondDeploy script
        deployDiamondScript = new DeployDiamond();
        deployedContracts = deployDiamondScript.run();
    }

    /// @dev Test that the Diamond contracts are correctly deployed.
    function test_DiamondContractsAreCorrectlyDeployed() public {
        assertTrue(
            deployedContracts.diamondCutFacetAddress != address(0)
                && deployedContracts.diamondCutFacetAddress.code.length != 0, 
            "TEST_DIAMOND_DEPLOY::DiamondCut facet not deployed."
        );
        assertTrue(
            deployedContracts.diamondInitAddress != address(0) 
                && deployedContracts.diamondInitAddress.code.length != 0, 
            "TEST_DIAMOND_DEPLOY::DiamondInit facet not deployed."
        );
        assertTrue(
            deployedContracts.diamondLoupeFacetAddress != address(0)
                && deployedContracts.diamondLoupeFacetAddress.code.length != 0, 
            "TEST_DIAMOND_DEPLOY::DiamondLoupe facet not deployed."
        );
        assertTrue(
            deployedContracts.diamondOwnershipFacetAddress != address(0) 
                && deployedContracts.diamondOwnershipFacetAddress.code.length != 0, 
            "TEST_DIAMOND_DEPLOY::Ownership facet not deployed."
        );
        assertTrue(
            deployedContracts.diamondAddress != address(0) 
                && deployedContracts.diamondAddress.code.length != 0, 
            "TEST_DIAMOND_DEPLOY::Diamond not deployed."
        );
    }

    /// @dev Test that the `_getSelectorsFromArtifact` function reverts correctly on empty argument
    function test_getSelectorsFromArtifact_EmptyString() public {
        vm.expectRevert(FacetHelper.EmptyString.selector);
        _getSelectorsFromArtifact("");
    }

    // @dev Test that the `_getSelectorsFromArtifact` function reverts correctly if its string argument contains whitespace
    function test_getSelectorsFromArtifact_ContainsWhitespace() public {
        string memory containsWhitespace = "DiamondLoupe Facet";
        
        vm.expectRevert(abi.encodeWithSelector(FacetHelper.ContainsWhitespace.selector, containsWhitespace));
        _getSelectorsFromArtifact(containsWhitespace);
    }

    /// @dev Test that the `_getSelectorsFromArtifacts` function reverts correctly if the contract does not contain functions
    function test_getSelectorsFromArtifact_NoSelectorsFound() public {
        string memory functionFreeContract = "FunctionFreeContract";

        vm.expectRevert(abi.encodeWithSelector(FacetHelper.NoSelectorsFound.selector, functionFreeContract));
        _getSelectorsFromArtifact(functionFreeContract);
    }

    /// @dev Test that the `_getSelectorsFromArtifacts` returns the correct selectors from the JSON file
    function test_FacetHelper_getCorrectSelectorsFromArtifact_DiamondLoupeFacet() public {
        bytes4[5] memory selectors = [bytes4(0xcdffacc6), 0x52ef6b2c, 0xadfca15e, 0x7a0ed627, 0x01ffc9a7];
        bytes4[] memory selectorsFromArtifact = _getSelectorsFromArtifact("DiamondLoupeFacet");

        for (uint256 i; i < selectors.length; i++) {
            assertEq(selectors[i], selectorsFromArtifact[i]);
        }
    }

    /// @dev Test that the diamond contract has the correct function selectors associated with the DiamondLoupe facet.
    function test_AddedValidFunctionSelectors_DiamondLoupeFacet() public {
        bytes4[] memory functionSelectorsFromLoupe = IDiamondLoupe(deployedContracts.diamondAddress).facetFunctionSelectors(deployedContracts.diamondLoupeFacetAddress);
        bytes4[] memory functionSelectorsFromArtifact = _getSelectorsFromArtifact("DiamondLoupeFacet");

        assertEq(
            keccak256(abi.encode(functionSelectorsFromLoupe)),
            keccak256(abi.encode(functionSelectorsFromArtifact))
        );
    }

    /// @dev Test that the diamond contract has the correct function selectors associated with the DiamondCut facet.
    function test_AddedValidFunctionSelectors_DiamondCutFacet() public {
        bytes4[] memory functionSelectorsFromLoupe = IDiamondLoupe(deployedContracts.diamondAddress).facetFunctionSelectors(deployedContracts.diamondCutFacetAddress);
        bytes4[] memory functionSelectorsFromArtifact = _getSelectorsFromArtifact("DiamondCutFacet");

        assertEq(
            keccak256(abi.encode(functionSelectorsFromLoupe)),
            keccak256(abi.encode(functionSelectorsFromArtifact))
        );
    }

    /// @dev Test that the diamond contract has the correct function selectors associated with the ownership facet.
    function test_AddedValidFunctionSelectors_OwnershipFacet() public {
        bytes4[] memory functionSelectorsFromLoupe = IDiamondLoupe(deployedContracts.diamondAddress).facetFunctionSelectors(deployedContracts.diamondOwnershipFacetAddress);
        bytes4[] memory functionSelectorsFromArtifact = _getSelectorsFromArtifact("OwnershipFacet");

        assertEq(
            keccak256(abi.encode(functionSelectorsFromLoupe)),
            keccak256(abi.encode(functionSelectorsFromArtifact))
        );
    }

    /// @dev Test that the owner of the diamond contract is the ENV file `DIAMOND_OWNER` address.
    function test_DiamondOwnerIsEnvAddress() public {
        address owner = IOwnershipFacet(deployedContracts.diamondAddress).owner();

        assertEq(owner, testData.diamondOwner);
    }
}