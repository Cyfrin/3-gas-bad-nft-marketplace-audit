/*
 * Certora Formal Verification Spec for NftMock
 */ 

using NftMock as nft;


methods {
    function mint() external; // This isn't env free because this will block ETH sent with this call. 
    function totalSupply() external returns(uint256) envfree ; // This is envfree because it's a view function, and the env doesn't matter
    function balanceOf(address) external returns(uint) envfree;
}

// Invariant 
// In order for this to pass, we need our conf to accept trivial invariant checks... but we don't want trivial invariant checks! 
invariant totalSupplyIsNotNegative() // trivial invariant check failed post-state assertion is trivially true
    totalSupply() >= 0;

rule minting_mints_one_nft() {
    // Arrange
    env e; 
    address minter;

    require e.msg.value == 0;
    require e.msg.sender == minter;

    // This could be uint256 or mathint
    // You could do `balanceOf(minter)` instead of `nft.balanceOf(minter)` but I like to be explicit
    mathint balanceBefore = nft.balanceOf(minter);

    // Act 
    currentContract.mint(e); 
    // We could also do `nft.mint(e)` 
    // or just `mint(e)` 

    // Assert
    assert to_mathint(nft.balanceOf(minter)) == balanceBefore + 1, "Only 1 NFT should be minted";
}

// This is known as a parametric rule, as there is a variable of type "method", which we named `f`
// This means, we call any random function `f` with any random calldata `arg` 
// We can also say which contracts we want to call f on, in this case, we said the nft contract
rule sanity {
    env e;
    calldataarg arg;
    method f;
    nft.f(e, arg);
    satisfy true;
}

// parametric rule example
rule no_change_to_total_supply(method f) {
    uint256 totalSupplyBefore = totalSupply();
    env e;
    calldataarg args;
    f(e, args);
    assert totalSupply() == totalSupplyBefore, "Total supply should not change";
}
