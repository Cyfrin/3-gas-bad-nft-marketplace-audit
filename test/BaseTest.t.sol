// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {NftMarketplace} from "src/NftMarketplace.sol";
import {NftMock} from "./mocks/NftMock.sol";
import {INftMarketplace} from "src/INftMarketplace.sol";

abstract contract BaseTest is Test {
    INftMarketplace public nftMarketplace;
    NftMock public nftMock;

    uint256 public constant STARTING_TOKEN_ID = 0;
    address public basicSeller = makeAddr("basicSeller");

    event ItemListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event ItemUpdated(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event ItemCanceled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);
    event ItemBought(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price);

    function setUp() public virtual {
        nftMarketplace = new NftMarketplace();
        nftMock = new NftMock();
    }

    /*//////////////////////////////////////////////////////////////
                                LIST ITEM
    //////////////////////////////////////////////////////////////*/
    function testCanListItem(address seller, uint256 price) public {
        vm.assume(seller != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(price > 0);

        _giveAndApproveNft(seller, STARTING_TOKEN_ID);

        vm.prank(seller);
        nftMarketplace.listItem(address(nftMock), STARTING_TOKEN_ID, price);

        assertEq(nftMarketplace.getListing(address(nftMock), STARTING_TOKEN_ID).price, price);
        assertEq(nftMarketplace.getListing(address(nftMock), STARTING_TOKEN_ID).seller, seller);
    }

    function testRevertsWithZeroPrice(address seller) public {
        vm.assume(seller != address(0));
        vm.assume(seller.code.length == 0);
        uint256 price = 0;

        _giveAndApproveNft(seller, STARTING_TOKEN_ID);

        vm.prank(seller);
        vm.expectRevert(NftMarketplace.NftMarketplace__PriceMustBeAboveZero.selector);
        nftMarketplace.listItem(address(nftMock), STARTING_TOKEN_ID, price);
    }

    function testListingNftEmitsEvents(address seller, uint256 price) public {
        vm.assume(seller != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(price > 0);

        _giveAndApproveNft(seller, STARTING_TOKEN_ID);

        vm.prank(seller);
        vm.expectEmit(true, true, true, true, address(nftMarketplace));
        emit ItemListed(seller, address(nftMock), STARTING_TOKEN_ID, price);
        nftMarketplace.listItem(address(nftMock), STARTING_TOKEN_ID, price);
    }

    function testListingNftMovesNft(address seller, uint256 price) public {
        vm.assume(seller != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(price > 0);

        _giveAndApproveNft(seller, STARTING_TOKEN_ID);

        vm.prank(seller);
        nftMarketplace.listItem(address(nftMock), STARTING_TOKEN_ID, price);
        assertEq(nftMock.ownerOf(STARTING_TOKEN_ID), address(nftMarketplace));
    }

    /*//////////////////////////////////////////////////////////////
                             CANCEL LISTING
    //////////////////////////////////////////////////////////////*/
    function testCanCanelListing(address seller, uint256 price) public {
        vm.assume(seller != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(price > 0);

        _giveAndApproveNft(seller, STARTING_TOKEN_ID);
        vm.prank(seller);
        nftMarketplace.listItem(address(nftMock), STARTING_TOKEN_ID, price);

        vm.prank(seller);
        nftMarketplace.cancelListing(address(nftMock), STARTING_TOKEN_ID);

        assertEq(nftMarketplace.getListing(address(nftMock), STARTING_TOKEN_ID).price, 0);
        assertEq(nftMarketplace.getListing(address(nftMock), STARTING_TOKEN_ID).seller, address(0));
        assertEq(nftMock.ownerOf(STARTING_TOKEN_ID), seller);
    }

    function testOnlySellerCanCanel(address seller, uint256 price, address fakeSeller) public {
        vm.assume(seller != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(price > 0);

        _giveAndApproveNft(seller, STARTING_TOKEN_ID);
        vm.prank(seller);
        nftMarketplace.listItem(address(nftMock), STARTING_TOKEN_ID, price);

        vm.expectRevert(NftMarketplace.NftMarketplace__NotOwner.selector);
        vm.prank(fakeSeller);
        nftMarketplace.cancelListing(address(nftMock), STARTING_TOKEN_ID);
    }

    function testCancellingEmitsEvent(address seller, uint256 price) public {
        vm.assume(seller != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(price > 0);

        _giveAndApproveNft(seller, STARTING_TOKEN_ID);
        vm.prank(seller);
        nftMarketplace.listItem(address(nftMock), STARTING_TOKEN_ID, price);

        vm.prank(seller);
        vm.expectEmit(true, true, true, false, address(nftMarketplace));
        emit ItemCanceled(seller, address(nftMock), STARTING_TOKEN_ID);
        nftMarketplace.cancelListing(address(nftMock), STARTING_TOKEN_ID);
    }

    /*//////////////////////////////////////////////////////////////
                             UPDATE LISTING
    //////////////////////////////////////////////////////////////*/
    function testUpdateListing(address seller, uint256 price, uint256 newAmount) public {
        vm.assume(seller != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(price > 0);
        vm.assume(newAmount > 0);

        _giveListing(seller, STARTING_TOKEN_ID, price);

        vm.prank(seller);
        nftMarketplace.updateListing(address(nftMock), STARTING_TOKEN_ID, newAmount);

        assertEq(nftMarketplace.getListing(address(nftMock), STARTING_TOKEN_ID).price, newAmount);
    }

    function testOnlySellerCanUpdateListing(address seller, uint256 price, uint256 newAmount, address fakeSeller)
        public
    {
        vm.assume(seller != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(price > 0);
        vm.assume(newAmount > 0);

        _giveListing(seller, STARTING_TOKEN_ID, price);

        vm.expectRevert(NftMarketplace.NftMarketplace__NotOwner.selector);
        vm.prank(fakeSeller);
        nftMarketplace.updateListing(address(nftMock), STARTING_TOKEN_ID, newAmount);
    }

    function testUpdateListingMustBeAboveZero(address seller, uint256 price) public {
        vm.assume(seller != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(price > 0);
        uint256 newAmount = 0;

        _giveListing(seller, STARTING_TOKEN_ID, price);

        vm.prank(seller);
        vm.expectRevert(NftMarketplace.NftMarketplace__PriceMustBeAboveZero.selector);
        nftMarketplace.updateListing(address(nftMock), STARTING_TOKEN_ID, newAmount);
    }

    function testUpdateListingEmitsEvent(address seller, uint256 price, uint256 newAmount) public {
        vm.assume(seller != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(price > 0);
        vm.assume(newAmount > 0);

        _giveListing(seller, STARTING_TOKEN_ID, price);

        vm.prank(seller);
        vm.expectEmit(true, true, true, true, address(nftMarketplace));
        emit ItemUpdated(seller, address(nftMock), STARTING_TOKEN_ID, newAmount);
        nftMarketplace.updateListing(address(nftMock), STARTING_TOKEN_ID, newAmount);
    }

    /*//////////////////////////////////////////////////////////////
                                BUY ITEM
    //////////////////////////////////////////////////////////////*/
    function testBuyItem(address seller, uint256 price, address buyer) public {
        vm.assume(seller != address(0));
        vm.assume(buyer != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(buyer.code.length == 0);
        vm.assume(price > 0);

        _giveListing(seller, STARTING_TOKEN_ID, price);

        vm.deal(buyer, price);
        vm.prank(buyer);
        nftMarketplace.buyItem{value: price}(address(nftMock), STARTING_TOKEN_ID);

        assertEq(nftMock.ownerOf(STARTING_TOKEN_ID), buyer);
        // We also test the listing is removed from the mapping
        assertEq(nftMarketplace.getListing(address(nftMock), STARTING_TOKEN_ID).price, 0);
        assertEq(nftMarketplace.getListing(address(nftMock), STARTING_TOKEN_ID).seller, address(0));

        // We also test the proceeds here, cuz we are lazy
        assertEq(nftMarketplace.getProceeds(seller), price);
    }

    function testBuyItemRevertsWhenBadTokenId(address seller, uint256 price, address buyer) public {
        vm.assume(seller != address(0));
        vm.assume(buyer != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(buyer.code.length == 0);
        vm.assume(price > 0);

        _giveListing(seller, STARTING_TOKEN_ID, price);

        uint256 badTokenId = 1;

        vm.deal(buyer, price);
        vm.prank(buyer);
        vm.expectRevert(
            abi.encodeWithSelector(NftMarketplace.NftMarketplace__NotListed.selector, address(nftMock), badTokenId)
        );

        nftMarketplace.buyItem{value: price}(address(nftMock), badTokenId);
    }

    function testBuyItemEmitsEvent(address seller, uint256 price, address buyer) public {
        vm.assume(seller != address(0));
        vm.assume(buyer != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(buyer.code.length == 0);
        vm.assume(price > 0);

        _giveListing(seller, STARTING_TOKEN_ID, price);

        vm.deal(buyer, price);
        vm.prank(buyer);
        vm.expectEmit(true, true, true, true, address(nftMarketplace));
        emit ItemBought(buyer, address(nftMock), STARTING_TOKEN_ID, price);
        nftMarketplace.buyItem{value: price}(address(nftMock), STARTING_TOKEN_ID);
    }

    function testBuyItemRevertsWhenPriceNotMet(address seller, uint256 price, address buyer) public {
        vm.assume(seller != address(0));
        vm.assume(buyer != address(0));
        vm.assume(seller.code.length == 0);
        vm.assume(buyer.code.length == 0);
        vm.assume(price > 0);

        _giveListing(seller, STARTING_TOKEN_ID, price);

        uint256 badPrice = price - 1;

        vm.deal(buyer, badPrice);
        vm.prank(buyer);
        vm.expectRevert(
            abi.encodeWithSelector(
                NftMarketplace.NftMarketplace__PriceNotMet.selector, address(nftMock), STARTING_TOKEN_ID, price
            )
        );
        nftMarketplace.buyItem{value: badPrice}(address(nftMock), STARTING_TOKEN_ID);
    }

    /*//////////////////////////////////////////////////////////////
                           WITHDRAW PROCEEDS
    //////////////////////////////////////////////////////////////*/
    function testWithdrawProceeds(address seller, uint256 price, address buyer) public {
        vm.assume(seller != address(0));
        vm.assume(buyer != address(0));
        vm.assume(seller.code.length == 0);
        // Idk, address 9 is giving issues for some reason
        vm.assume(seller != address(9));
        vm.assume(buyer.code.length == 0);
        vm.assume(price > 0);

        uint256 startingSellerBalance = address(seller).balance;

        _giveListing(seller, STARTING_TOKEN_ID, price);

        vm.deal(buyer, price);
        vm.prank(buyer);
        nftMarketplace.buyItem{value: price}(address(nftMock), STARTING_TOKEN_ID);

        vm.prank(seller);
        nftMarketplace.withdrawProceeds();

        assertEq(nftMarketplace.getProceeds(seller), 0);
        assertEq(address(seller).balance, startingSellerBalance + price);
    }

    function testCantWithdrawZeroProceeds(address seller) public {
        vm.assume(seller != address(0));
        vm.assume(seller.code.length == 0);

        vm.prank(seller);
        vm.expectRevert(NftMarketplace.NftMarketplace__NoProceeds.selector);
        nftMarketplace.withdrawProceeds();
    }

    /*//////////////////////////////////////////////////////////////
                            ONERC721RECEIVED
    //////////////////////////////////////////////////////////////*/
    function testOnERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) public {
        assertEq(
            nftMarketplace.onERC721Received(operator, from, tokenId, data), NftMarketplace.onERC721Received.selector
        );
    }

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/
    function _giveAndApproveNft(address to, uint256 tokenId) internal {
        vm.startPrank(to);
        nftMock.mint();
        nftMock.approve(address(nftMarketplace), tokenId);
        vm.stopPrank();
    }

    function _giveListing(address to, uint256 tokenId, uint256 price)
        internal
        returns (NftMarketplace.Listing memory)
    {
        _giveAndApproveNft(to, tokenId);
        vm.prank(to);
        nftMarketplace.listItem(address(nftMock), STARTING_TOKEN_ID, price);
        return nftMarketplace.getListing(address(nftMock), STARTING_TOKEN_ID);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
