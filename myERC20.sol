// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title 带有增发功能的ERC20代币合约
 * @dev 实现了标准ERC20功能，并添加了仅所有者可调用的mint函数
 */
contract MYERC20 {
    // 代币基本信息
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // 余额存储
    mapping(address => uint256) public balanceOf;
    // 授权存储
    mapping(address => mapping(address => uint256)) public allowance;

    // 所有者地址
    address private _owner;

    // 事件定义
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev 构造函数，初始化代币信息并设置部署者为所有者
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _owner = msg.sender;

        // 初始化代币供应，分配给合约部署者
        uint256 initialSupplyWithDecimals = _initialSupply *
            (10 ** uint256(_decimals));
        totalSupply = initialSupplyWithDecimals;
        balanceOf[msg.sender] = initialSupplyWithDecimals;
        emit Transfer(address(0), msg.sender, initialSupplyWithDecimals);
    }

    /**
     * @dev 转移合约所有权
     * @param newOwner 新所有者地址
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "ERC20WithMint: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev 获取当前所有者地址
     * @return 当前所有者地址
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev 代币增发功能，仅所有者可调用
     * @param to 接收增发代币的地址
     * @param amount 增发的代币数量（已考虑decimals的实际数量）
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "ERC20WithMint: mint to the zero address");

        // 增发代币，增加总供应量和接收者余额
        totalSupply += amount;
        balanceOf[to] += amount;

        // 触发转账事件，from为零地址表示新发行的代币
        emit Transfer(address(0), to, amount);
    }

    /**
     * @dev 转账功能
     * @param to 接收地址
     * @param value 转账数量（最小单位）
     * @return 成功返回true
     */
    function transfer(address to, uint256 value) public returns (bool) {
        require(
            to != address(0),
            "ERC20WithMint: transfer to the zero address"
        );
        require(
            balanceOf[msg.sender] >= value,
            "ERC20WithMint: insufficient balance"
        );

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev 授权功能
     * @param spender 被授权地址
     * @param value 授权数量（最小单位）
     * @return 成功返回true
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(
            spender != address(0),
            "ERC20WithMint: approve to the zero address"
        );

        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(
            to != address(0),
            "ERC20WithMint: transfer to the zero address"
        );
        require(
            balanceOf[msg.sender] >= value,
            "ERC20WithMint: insufficient balance"
        );

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev 从授权地址转账
     * @param from 转出地址
     * @param to 接收地址
     * @param value 转账数量（最小单位）
     * @return 成功返回true
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(
            from != address(0),
            "ERC20WithMint: transfer from the zero address"
        );
        require(
            to != address(0),
            "ERC20WithMint: transfer to the zero address"
        );
        require(
            balanceOf[from] >= value,
            "ERC20WithMint: insufficient balance"
        );
        require(
            allowance[from][msg.sender] >= value,
            "ERC20WithMint: allowance exceeded"
        );

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    /**
     * @dev 修饰符，限制只有所有者可以调用
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "ERC20WithMint: caller is not the owner");
        _;
    }
}
