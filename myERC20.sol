// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyERC20 {
    // 代币名称
    string public name;
    // 代币符号
    string public symbol;
    // 小数位数
    uint8 public decimals;
    // 总供应量
    uint256 public totalSupply;

    // 存储每个地址的余额
    mapping(address => uint256) public balanceOf;
    // 存储授权信息: owner允许spender花费的代币数量
    mapping(address => mapping(address => uint256)) public allowance;

    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 授权事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * 构造函数，初始化代币信息
     * @param _name 代币名称
     * @param _symbol 代币符号
     * @param _decimals 小数位数
     * @param _totalSupply 总供应量
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * (10 ** uint256(_decimals));
        // 将初始代币分配给合约部署者
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /**
     * 转账功能
     * @param to 接收地址
     * @param value 转账数量
     * @return 成功返回true
     */
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Transfer to the zero address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * 授权功能，允许spender花费指定数量的代币
     * @param spender 被授权地址
     * @param value 授权数量
     * @return 成功返回true
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "Approve to the zero address");

        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * 从授权地址转账
     * @param from 转出地址
     * @param to 接收地址
     * @param value 转账数量
     * @return 成功返回true
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(balanceOf[from] >= value, "ERC20: insufficient balance");
        require(
            allowance[from][msg.sender] >= value,
            "ERC20: allowance exceeded"
        );

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    modifier onlyOwner() {
        require(msg.sender == address(this), "ERC20: caller is not the owner");
        _;
    }
}
