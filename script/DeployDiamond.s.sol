// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Script } from "forge-std/Script.sol";
import { IDiamondCut } from "src/interfaces/IDiamondCut.sol";
import { IDiamond } from "src/interfaces/IDiamond.sol";
import { Diamond, DiamondArgs } from "src/Diamond.sol";
import { DiamondCutFacet } from "src/facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "src/facets/DiamondLoupeFacet.sol";
import { OwnershipFacet } from "src/facets/OwnershipFacet.sol";
import { DiamondInit } from "src/upgradeInitializers/DiamondInit.sol";
import { FacetHelper } from "helpers/FacetHelper.sol";
import { AppStorageInitData } from "src/libraries/LibInit.sol";

struct DeployedContracts {
    address diamondCutFacetAddress;
    address diamondAddress;
    address diamondInitAddress;
    address diamondLoupeFacetAddress;
    address diamondOwnershipFacetAddress;
}

/// @notice Forge script to deploy a standard EIP-2535 Diamond (impl-1) including the `DiamondLoupeFacet` and `OwnershipFacet`.
/// @dev To deploy LOCALLY with Anvil, make sure you provided a `LOCAL_DEPLOYER_PRIVATE_KEY` inside the `.env` file prior to 
/// running the following script.
/// The ownership of all the contracts deployed by this script is assigned to the `.env` file variable 
/// `LOCAL_DEPLOYER_PRIVATE_KEY`, you can use one provided from Anvil for testing purposes.
/// (more info: https://book.getfoundry.sh/tutorials/solidity-scripting#deploying-locally)
///
/// Command to deploy the standard Diamond LOCALLY on the Anvil environment:
///     forge script script/DeployDiamond.s.sol:DeployDiamond \
///     --ffi \
///     --fork-url http://localhost:8545 \
///     --broadcast
contract DeployDiamond is Script, FacetHelper {
    error NotDeployed(string contractName);

    IDiamond.FacetCut[] diamondCut;

    /// @dev Defines data to be initilized inside the AppStorage during the DiamondCut
    AppStorageInitData appStorageInitData = AppStorageInitData({
        app_name: "diamond-1-foundry"
    });

    /// @dev Function to deploy the diamond contract with specified facets and initialize its AppStorage
    /// with appStorageInitData via the DiamondInit.init() function.
    /// @return deployedContracts A struct of deployed contracts addresses.
    function run() external returns(DeployedContracts memory deployedContracts){
        uint256 deployerPK = vm.envUint("LOCAL_DEPLOYER_PRIVATE_KEY");
        address diamondOwner = vm.envAddress("DIAMOND_OWNER");
        bytes4[] memory diamondCutFacetSelectors = _getSelectorsFromArtifact("DiamondCutFacet");
        bytes4[] memory diamondLoupeFacetSelectors = _getSelectorsFromArtifact("DiamondLoupeFacet");
        bytes4[] memory diamondOwnershipFacetSelectors = _getSelectorsFromArtifact("OwnershipFacet");

        vm.startBroadcast(deployerPK);

        deployedContracts.diamondCutFacetAddress = address(new DiamondCutFacet());
        if (deployedContracts.diamondCutFacetAddress == address(0)) revert NotDeployed("DiamondCutFacet");

        deployedContracts.diamondLoupeFacetAddress = address(new DiamondLoupeFacet());
        if (deployedContracts.diamondLoupeFacetAddress == address(0)) revert NotDeployed("DiamondLoupeFacet");

        deployedContracts.diamondOwnershipFacetAddress = address(new OwnershipFacet());
        if (deployedContracts.diamondOwnershipFacetAddress == address(0)) revert NotDeployed("OwnershipFacet");

        deployedContracts.diamondInitAddress = address(new DiamondInit());
        if (deployedContracts.diamondInitAddress == address(0)) revert NotDeployed("DiamondInit");

        diamondCut.push(IDiamond.FacetCut({
            facetAddress: deployedContracts.diamondCutFacetAddress,
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: diamondCutFacetSelectors
        }));
        diamondCut.push(IDiamond.FacetCut({
            facetAddress: deployedContracts.diamondLoupeFacetAddress,
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: diamondLoupeFacetSelectors
        }));
        diamondCut.push(IDiamond.FacetCut({
            facetAddress: deployedContracts.diamondOwnershipFacetAddress,
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: diamondOwnershipFacetSelectors
        }));

        DiamondArgs memory args = DiamondArgs({
            owner: diamondOwner,
            init: deployedContracts.diamondInitAddress,
            initCalldata: abi.encodeWithSelector(DiamondInit.init.selector, appStorageInitData)
        });

        deployedContracts.diamondAddress = address(new Diamond(diamondCut, args));
        if (deployedContracts.diamondAddress == address(0)) revert NotDeployed("Diamond");

        vm.stopBroadcast();
    }
}
