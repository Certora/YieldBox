// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

// with mint
contract DummyERC20Impl {
    uint256 t;
    mapping (address => uint256) b;
    mapping (address => mapping (address => uint256)) a;

    string public name;
    string public symbol;
    uint public decimals;

    function myAddress() public returns (address) {
        return address(this);
    }

    function add(uint a, uint b) internal pure returns (uint256) {
        uint c = a +b;
        require (c >= a);
        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint256) {
        require (a>=b);
        return a-b;
    }

    function totalSupply() external view returns (uint256) {
        return t;
    }
    function balanceOf(address account) external view returns (uint256) {
        return b[account];
    }
    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(msg.sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        b[msg.sender] = sub(b[msg.sender], amount);
        b[recipient] = add(b[recipient], amount);
        return true;
    }
    function allowance(address owner, address spender) external view returns (uint256) {
        return a[owner][spender];
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        a[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(sender != address(0), "ERC20: transfer from the zero address");

        b[sender] = sub(b[sender], amount);
        b[recipient] = add(b[recipient], amount);
        a[sender][msg.sender] = sub(a[sender][msg.sender], amount);
        return true;
    }
}

contract DummyMintableERC20Impl is DummyERC20Impl {
    address public minter;

    modifier onlyMinter() {
        require (msg.sender == minter, "Mint callable by minter only");
        _;
    }

    // constructor (address _minter) {
    //     minter = _minter;
    // }

    function mint(address account, uint256 amount) external onlyMinter() {
        _mint(account, amount);
    }

    function _mint(address user, uint256 amount) internal {
        t += amount;
        b[user] += amount;
    }
}

contract DummyBoringERC20Impl is DummyMintableERC20Impl {
    /// Mock implementations for the non-standard extensions that boring tokens have

    bool _mockShouldAllowAll;

    // This is meant to be some kind of approval mechanism, utulizing on-chain signing of approval messages.
    // The original functionality just reverts if not approved, so this mock can be controlled from CVL.
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        a[owner][spender] = value;
    }

    // Not sure if that's nessecary for the tool, 
    // (but maybe helps with rules that want to check things dynamically specifically with that behavior)
    function changeBehavior(bool new_behavior) public {
        _mockShouldAllowAll = new_behavior;
    }
}

