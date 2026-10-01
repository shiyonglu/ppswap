// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ppswap.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MOCK") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract PPSwapTest is Test {
    PPSwap ppswap;
    MockToken mockToken;

    address alice = makeAddr("alice");
    address bob   = makeAddr("bob");

    function setUp() public {
        ppswap = new PPSwap(payable(address(this)));
        mockToken = new MockToken();

        // Give Alice tokens to sell
        mockToken.mint(alice, 1000 ether);

        // Give Bob ETH to buy tokens/PPS
        vm.deal(bob, 10 ether);
    }

    function testInitialSupply() public {
        uint256 totalSupply = ppswap.totalSupply();

        assertEq(
            totalSupply,
            ppswap.INITIAL_SUPPLY()
        );

        // All PPS initially belongs to the PPSwap contract
        assertEq(
            ppswap.balanceOf(address(ppswap)),
            totalSupply
        );
    }

    function testBuyPPS() public {
        uint256 ppsBefore = ppswap.balanceOf(bob);
        uint256 ethBefore = address(ppswap).balance;

        vm.prank(bob);
        ppswap.buyPPS{value: 0.5 ether}();

        uint256 ppsAfter = ppswap.balanceOf(bob);
        uint256 ethAfter = address(ppswap).balance;

        // price = 0.0001 ETH / PPS
        // 0.5 ETH buys 5000 PPS
        assertEq(
            ppsAfter - ppsBefore,
            5000 ether
        );

        assertEq(
            ethAfter - ethBefore,
            0.5 ether
        );
    }

    function testSellPPS() public {
        // Bob first buys PPS so the contract has ETH
        vm.prank(bob);
        ppswap.buyPPS{value: 1 ether}();

        uint256 bobEthBefore = bob.balance;
        uint256 bobPPSBefore = ppswap.balanceOf(bob);

        // Sell 1000 PPS
        vm.prank(bob);
        ppswap.sellPPS(1000 ether);

        uint256 bobEthAfter = bob.balance;
        uint256 bobPPSAfter = ppswap.balanceOf(bob);

        // 1000 PPS * 0.0001 ETH = 0.1 ETH
        assertEq(
            bobEthAfter - bobEthBefore,
            0.1 ether
        );

        assertEq(
            bobPPSBefore - bobPPSAfter,
            1000 ether
        );
    }

    function testListToken() public {
        vm.startPrank(alice);

        // Alice must explicitly approve PPSwap
        mockToken.approve(address(ppswap), 1000 ether);

        uint256 offerID = ppswap.listToken(
            address(mockToken),
            0.01 ether,
            100 ether
        );

        vm.stopPrank();

        assertEq(offerID, 1);
        assertEq(ppswap.lastOfferID(), 1);
    }

    function testBuyListedToken() public {
        // Alice approves PPSwap to spend her MOCK
        vm.startPrank(alice);

        mockToken.approve(
            address(ppswap),
            1000 ether
        );

        uint256 offerID = ppswap.listToken(
            address(mockToken),
            0.01 ether,   // 0.01 ETH per token
            100 ether
        );

        vm.stopPrank();

        uint256 aliceTokenBefore = mockToken.balanceOf(alice);
        uint256 bobTokenBefore = mockToken.balanceOf(bob);
        uint256 aliceEthBefore = alice.balance;

        // Bob spends 0.02 ETH -> receives 2 tokens
        vm.prank(bob);
        ppswap.buyToken{value: 0.02 ether}(offerID);

        assertEq(
            mockToken.balanceOf(bob) - bobTokenBefore,
            2 ether
        );

        assertEq(
            aliceTokenBefore - mockToken.balanceOf(alice),
            2 ether
        );

        assertEq(
            alice.balance - aliceEthBefore,
            0.02 ether
        );
    }

    function testCancelList() public {
        vm.startPrank(alice);

        mockToken.approve(
            address(ppswap),
            1000 ether
        );

        uint256 offerID = ppswap.listToken(
            address(mockToken),
            0.01 ether,
            100 ether
        );

        ppswap.cancelList(offerID);

        vm.stopPrank();

        (, , , , PPSwap.OfferStatus status) =
            ppswap.offers(offerID);

        assertEq(
            uint256(status),
            uint256(PPSwap.OfferStatus.Cancelled)
        );
    }
}
