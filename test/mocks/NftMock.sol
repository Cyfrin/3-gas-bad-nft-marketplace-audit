// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721Enumerable, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract NftMock is ERC721Enumerable {
    constructor() ERC721("NftMock", "NFTMOCK") {}

    function mint() external {
        _safeMint(msg.sender, totalSupply());
    }
}
