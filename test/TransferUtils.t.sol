// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { Test } from "forge-std/Test.sol";

import { TransferUtils } from "src/lib/TransferUtils.sol";
import { MockEtherReceiver } from "src/mocks/MockEtherReceiver.sol";
import { MockTransferUtils } from "src/mocks/MockTransferUtils.sol";

contract TransferUtilsTest is Test {
    MockTransferUtils internal mockUtils;
    MockEtherReceiver internal receiverContract;

    address public receiverWallet;

    uint256 public constant INITIAL_BALANCE = 10 ether;

    function setUp() public {
        mockUtils = new MockTransferUtils();
        receiverContract = new MockEtherReceiver();

        receiverWallet = makeAddr("receiver");

        vm.deal(address(mockUtils), INITIAL_BALANCE);
    }

    function test_TransferNative_ToEOA() public {
        uint256 transferAmount = 1 ether;

        mockUtils.transferNative(receiverWallet, transferAmount);

        assertEq(receiverWallet.balance, transferAmount);
        assertEq(address(mockUtils).balance, INITIAL_BALANCE - transferAmount);
    }

    function test_TransferNative_ToReceivingContract() public {
        uint256 transferAmount = 1 ether;

        receiverContract.toggleReceive(true);

        mockUtils.transferNative(address(receiverContract), transferAmount);

        assertEq(address(receiverContract).balance, transferAmount);
        assertEq(address(mockUtils).balance, INITIAL_BALANCE - transferAmount);
    }

    function test_TransferNative_ZeroAmount() public {
        mockUtils.transferNative(receiverWallet, 0);

        assertEq(receiverWallet.balance, 0);
        assertEq(address(mockUtils).balance, INITIAL_BALANCE);
    }

    function test_TransferNative_FullBalance() public {
        mockUtils.transferNative(receiverWallet, INITIAL_BALANCE);

        assertEq(receiverWallet.balance, INITIAL_BALANCE);
        assertEq(address(mockUtils).balance, 0);
    }

    function test_TransferNative_ReceiverRejects_Reverts() public {
        uint256 transferAmount = 1 ether;

        receiverContract.toggleReceive(false);

        vm.expectRevert(
            abi.encodeWithSelector(TransferUtils.TransferFailed.selector, address(receiverContract), transferAmount)
        );
        mockUtils.transferNative(address(receiverContract), transferAmount);

        assertEq(address(receiverContract).balance, 0);
    }

    function test_TransferNative_InsufficientBalance_Reverts() public {
        uint256 transferAmount = INITIAL_BALANCE + 1;

        vm.expectRevert(abi.encodeWithSelector(TransferUtils.TransferFailed.selector, receiverWallet, transferAmount));
        mockUtils.transferNative(receiverWallet, transferAmount);

        assertEq(receiverWallet.balance, 0);
    }

    function testFuzz_TransferNative_ToEOA(uint256 amount) public {
        amount = bound(amount, 0, 100 ether);
        vm.deal(address(mockUtils), amount);

        mockUtils.transferNative(receiverWallet, amount);

        assertEq(receiverWallet.balance, amount);
    }
}
