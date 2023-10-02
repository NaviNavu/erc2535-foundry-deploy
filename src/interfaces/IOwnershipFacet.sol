pragma solidity ^0.8.0;

interface IOwnershipFacet {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function owner() external view returns (address owner_);

    function transferOwnership(address _newOwner) external;
}
