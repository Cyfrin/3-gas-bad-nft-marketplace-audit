// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface INftMarketplace is IERC721Receiver {
    struct Listing {
        uint256 price;
        address seller;
    }

    function listItem(address nftAddress, uint256 tokenId, uint256 price) external;
    function cancelListing(address nftAddress, uint256 tokenId) external;
    function buyItem(address nftAddress, uint256 tokenId) external payable;
    function withdrawProceeds() external;
    function updateListing(address nftAddress, uint256 tokenId, uint256 price) external;
    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory);
    function getProceeds(address seller) external view returns (uint256 amount);
}
